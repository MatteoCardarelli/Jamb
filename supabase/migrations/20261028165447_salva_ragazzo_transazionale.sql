-- Salvataggio transazionale dell'aggregato "ragazzo".
--
-- Prima l'app scriveva su sei tabelle con chiamate separate: un errore a metà
-- (rete, permesso negato, valore non valido) lasciava dati parziali, ad esempio
-- specialità cancellate e mai reinserite. Una funzione PL/pgSQL viene eseguita
-- in un'unica transazione: o vanno a buon fine tutte le scritture, o nessuna.
--
-- SECURITY INVOKER: la funzione gira con i permessi di chi la chiama, quindi
-- le policy RLS restano l'unico controllo di accesso, esattamente come prima.
-- search_path = public perché le funzioni di supporto usate dalle policy
-- (es. ruolo_in_unita) fanno riferimento a tabelle senza schema.
--
-- Forma di p_ragazzo (costruita da SupabaseScoutRepository):
-- {
--   "id": uuid, "ruolo": text, "squadriglia": text,
--   "tappa": {"tipo": text, "impegni": [{"titolo", "isCompletato"}]},
--   "specialita": [{"nome", "prove": [...], "data_conseguimento": "AAAA-MM-GG" | null}],
--   "brevetti": [{"nome", "specialita_collegate": [...], "prova_finale_superata",
--                 "prova_finale_descrizione", "data_conseguimento"}],
--   "allergie": text, "contatti_emergenza": [{"nome", "telefono"}],
--   "stato_censimento", "stato_privacy", "stato_medica": text,
--   "scadenza_privacy", "scadenza_medica": "AAAA-MM-GG" | null
-- }

CREATE OR REPLACE FUNCTION "public"."salva_ragazzo"("p_unit_id" "uuid", "p_ragazzo" "jsonb")
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_user_id    uuid := (p_ragazzo->>'id')::uuid;
  -- L'anno scout va da settembre ad agosto, nel formato "AAAA-AAAA".
  v_inizio     integer := extract(year from current_date)::integer
                          - CASE WHEN extract(month from current_date) >= 9 THEN 0 ELSE 1 END;
  v_anno_scout text := v_inizio || '-' || (v_inizio + 1);
  v_corrente   record;
  v_squad_id   uuid;
  v_ruolo      public.ruolo_enum;
  v_righe      integer;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Id del ragazzo mancante' USING ERRCODE = '22023';
  END IF;

  -- 0. Membership (SCD Type 2): se ruolo o squadriglia sono cambiati,
  --    chiude la membership attiva e ne apre una nuova.
  IF p_unit_id IS NOT NULL THEN
    SELECT id, ruolo, squad_id, anno_scout INTO v_corrente
      FROM public.memberships
     WHERE user_id = v_user_id AND unit_id = p_unit_id AND is_active;

    IF FOUND THEN
      IF trim(coalesce(p_ragazzo->>'squadriglia', '')) <> '' THEN
        SELECT id INTO v_squad_id
          FROM public.squads
         WHERE unit_id = p_unit_id AND nome = p_ragazzo->>'squadriglia';
      END IF;

      -- Un ruolo non riconosciuto viene ignorato invece di far fallire il salvataggio.
      IF p_ragazzo->>'ruolo' = ANY (enum_range(NULL::public.ruolo_enum)::text[]) THEN
        v_ruolo := (p_ragazzo->>'ruolo')::public.ruolo_enum;
      END IF;

      IF (v_ruolo IS NOT NULL AND v_ruolo <> v_corrente.ruolo)
         OR (v_squad_id IS NOT NULL AND v_squad_id IS DISTINCT FROM v_corrente.squad_id) THEN
        UPDATE public.memberships
           SET is_active = false, data_fine = current_date
         WHERE id = v_corrente.id;
        GET DIAGNOSTICS v_righe = ROW_COUNT;
        -- Sotto RLS un UPDATE non autorizzato non dà errore, tocca zero righe.
        IF v_righe = 0 THEN
          RAISE EXCEPTION 'Non autorizzato a modificare ruolo o squadriglia'
            USING ERRCODE = '42501';
        END IF;

        INSERT INTO public.memberships
          (user_id, unit_id, squad_id, ruolo, is_active, anno_scout, data_inizio)
        VALUES
          (v_user_id, p_unit_id, coalesce(v_squad_id, v_corrente.squad_id),
           coalesce(v_ruolo, v_corrente.ruolo), true,
           coalesce(v_corrente.anno_scout, v_anno_scout), current_date);
      END IF;
    END IF;
  END IF;

  -- 1. Tappa (replace: cancella e reinserisce quella attuale).
  DELETE FROM public.user_tappe WHERE user_id = v_user_id;
  IF coalesce(p_ragazzo#>>'{tappa,tipo}', 'nulla') <> 'nulla'
     OR jsonb_array_length(coalesce(p_ragazzo#>'{tappa,impegni}', '[]'::jsonb)) > 0 THEN
    INSERT INTO public.user_tappe (user_id, tipo, impegni, anno_scout)
    VALUES (v_user_id,
            coalesce(p_ragazzo#>>'{tappa,tipo}', 'nulla')::public.tappa_sentiero_enum,
            coalesce(p_ragazzo#>'{tappa,impegni}', '[]'::jsonb),
            v_anno_scout);
  END IF;

  -- 2. Specialità (replace).
  DELETE FROM public.user_specialita WHERE user_id = v_user_id;
  INSERT INTO public.user_specialita (user_id, nome, prove, data_conseguimento)
  SELECT v_user_id,
         (s->>'nome')::public.specialita_nome_enum,
         coalesce(s->'prove', '[]'::jsonb),
         (s->>'data_conseguimento')::date
    FROM jsonb_array_elements(coalesce(p_ragazzo->'specialita', '[]'::jsonb)) AS s;

  -- 3. Brevetti (replace).
  DELETE FROM public.user_brevetti WHERE user_id = v_user_id;
  INSERT INTO public.user_brevetti
    (user_id, nome, specialita_collegate, prova_finale_superata,
     prova_finale_descrizione, data_conseguimento)
  SELECT v_user_id,
         (b->>'nome')::public.brevetto_nome_enum,
         coalesce(b->'specialita_collegate', '[]'::jsonb),
         coalesce((b->>'prova_finale_superata')::boolean, false),
         b->>'prova_finale_descrizione',
         (b->>'data_conseguimento')::date
    FROM jsonb_array_elements(coalesce(p_ragazzo->'brevetti', '[]'::jsonb)) AS b;

  -- 4. Dati sensibili (upsert, non delete: preserva note_mediche, che
  --    l'app non modella e non deve sovrascrivere).
  INSERT INTO public.user_dati_sensibili (user_id, allergie, contatti_emergenza)
  VALUES (v_user_id,
          p_ragazzo->>'allergie',
          coalesce(p_ragazzo->'contatti_emergenza', '[]'::jsonb))
  ON CONFLICT (user_id) DO UPDATE
    SET allergie = excluded.allergie,
        contatti_emergenza = excluded.contatti_emergenza;

  -- 5. Stati amministrativi e scadenze.
  UPDATE public.users
     SET stato_censimento = (p_ragazzo->>'stato_censimento')::public.stato_doc_enum,
         stato_privacy    = (p_ragazzo->>'stato_privacy')::public.stato_doc_enum,
         stato_medica     = (p_ragazzo->>'stato_medica')::public.stato_doc_enum,
         scadenza_privacy = (p_ragazzo->>'scadenza_privacy')::date,
         scadenza_medica  = (p_ragazzo->>'scadenza_medica')::date
   WHERE id = v_user_id;
  GET DIAGNOSTICS v_righe = ROW_COUNT;
  IF v_righe = 0 THEN
    RAISE EXCEPTION 'Ragazzo non trovato o non modificabile' USING ERRCODE = '42501';
  END IF;
END;
$$;

ALTER FUNCTION "public"."salva_ragazzo"("uuid", "jsonb") OWNER TO "postgres";

-- Solo gli utenti autenticati possono chiamarla (le policy decidono il resto).
REVOKE ALL ON FUNCTION "public"."salva_ragazzo"("uuid", "jsonb") FROM PUBLIC, "anon";
GRANT EXECUTE ON FUNCTION "public"."salva_ragazzo"("uuid", "jsonb") TO "authenticated", "service_role";
