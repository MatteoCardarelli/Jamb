-- Aggiungere i ragazzi (piano, sezione 9-bis, GP.2).
--
-- Il Capo Unità (o il Capo Gruppo) crea la scheda di un ragazzo e la sua
-- membership nell'unità in una sola transazione. La funzione è SECURITY
-- INVOKER: decidono le policy, `users_insert` qui sotto e `memberships_insert`
-- (Capo Unità solo ruoli da ragazzo, persona dello stesso gruppo).
-- Per togliere un ragazzo dall'unità basta chiudere la membership
-- (`memberships_update`, già esistente): la scheda e i dati restano.

-- 1. Chi può creare una scheda: Capo Gruppo o Capo Unità, nel proprio gruppo,
--    sempre senza account. Una scheda senza membership resterebbe invisibile
--    anche a chi l'ha creata: per questo si passa dalla funzione.
CREATE POLICY "users_insert" ON "public"."users" FOR INSERT TO "authenticated"
  WITH CHECK (
    "group_id" = "public"."mio_group_id"()
    AND NOT "account_attivo"
    AND (
      "public"."is_capo_gruppo"()
      OR EXISTS (
        SELECT 1 FROM "public"."memberships" m
        WHERE m.user_id = auth.uid() AND m.is_active
          AND m.ruolo >= 'CAPO_UNITA'::"public"."ruolo_enum"
      )
    )
  );

-- 2. Scheda e membership insieme. La squadriglia si indica per nome, come in
--    `salva_ragazzo` (tra quelle attive dell'unità; vuota = nessuna).
CREATE FUNCTION "public"."aggiungi_ragazzo"(
    "p_unit_id" "uuid",
    "p_nome" "text",
    "p_cognome" "text",
    "p_data_nascita" "date",
    "p_squadriglia" "text",
    "p_ruolo" "public"."ruolo_enum"
) RETURNS "uuid"
    LANGUAGE "plpgsql"
    SET search_path = public
    AS $$
DECLARE
  v_id       uuid := gen_random_uuid();
  v_gruppo   uuid;
  v_squad_id uuid;
  v_inizio   integer := extract(year from current_date)::integer
                        - CASE WHEN extract(month from current_date) >= 9 THEN 0 ELSE 1 END;
BEGIN
  IF btrim(coalesce(p_nome, '')) = '' OR btrim(coalesce(p_cognome, '')) = '' THEN
    RAISE EXCEPTION 'Nome e cognome sono obbligatori' USING ERRCODE = '23514';
  END IF;
  IF p_ruolo NOT IN ('RAGAZZO', 'VICE_CAPO_SQ', 'CAPO_SQ') THEN
    RAISE EXCEPTION 'Ruolo non valido per un ragazzo' USING ERRCODE = '23514';
  END IF;

  -- L'unità si vede solo se è del proprio gruppo (units_select).
  SELECT group_id INTO v_gruppo FROM public.units WHERE id = p_unit_id;
  IF v_gruppo IS NULL THEN
    RAISE EXCEPTION 'Unità non trovata' USING ERRCODE = '42501';
  END IF;

  IF btrim(coalesce(p_squadriglia, '')) <> '' THEN
    SELECT id INTO v_squad_id FROM public.squads
     WHERE unit_id = p_unit_id AND is_active
       AND lower(btrim(nome)) = lower(btrim(p_squadriglia));
    IF v_squad_id IS NULL THEN
      RAISE EXCEPTION 'Squadriglia non trovata in questa unità' USING ERRCODE = '23514';
    END IF;
  END IF;

  INSERT INTO public.users (id, group_id, nome, cognome, data_nascita)
  VALUES (v_id, v_gruppo, btrim(p_nome), btrim(p_cognome), p_data_nascita);

  INSERT INTO public.memberships (user_id, unit_id, squad_id, ruolo, is_active, anno_scout, data_inizio)
  VALUES (v_id, p_unit_id, v_squad_id, p_ruolo, true, v_inizio || '-' || (v_inizio + 1), current_date);

  RETURN v_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION "public"."aggiungi_ragazzo"("uuid", "text", "text", "date", "text", "public"."ruolo_enum") FROM PUBLIC, "anon";
GRANT EXECUTE ON FUNCTION "public"."aggiungi_ragazzo"("uuid", "text", "text", "date", "text", "public"."ruolo_enum") TO "authenticated", "service_role";
