-- Sottogruppi delle branche (US20).
--
-- Squadriglie e sestiglie restano nella tabella `squads`; i loro nomi diventano
-- unici nell'unità perché `salva_ragazzo` e la bacheca le cercano per nome.
-- Il Consiglio Capi si ricava dalle memberships. Alta Squadriglia e Consiglio
-- della Rupe hanno membri scelti a mano: tabelle `sottogruppi` e
-- `sottogruppo_membri`, una riga per tipo e unità.
--
-- Li gestisce il Capo Unità (decisione dell'utente del 2026-11-08), la stessa
-- soglia delle policy di `squads`; li leggono i capi dell'unità.

ALTER TABLE "public"."squads"
  ADD CONSTRAINT "squads_nome_check" CHECK (btrim("nome") <> '');

CREATE UNIQUE INDEX "squads_unit_nome_unico"
  ON "public"."squads" ("unit_id", lower(btrim("nome")));

CREATE TABLE "public"."sottogruppi" (
  "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  "unit_id" uuid NOT NULL REFERENCES "public"."units"("id") ON DELETE CASCADE,
  "tipo" text NOT NULL CHECK ("tipo" IN ('alta_squadriglia', 'consiglio_rupe')),
  UNIQUE ("unit_id", "tipo")
);

CREATE TABLE "public"."sottogruppo_membri" (
  "sottogruppo_id" uuid NOT NULL REFERENCES "public"."sottogruppi"("id") ON DELETE CASCADE,
  "user_id" uuid NOT NULL REFERENCES "public"."users"("id") ON DELETE CASCADE,
  PRIMARY KEY ("sottogruppo_id", "user_id")
);

CREATE INDEX "idx_sottogruppo_membri_user" ON "public"."sottogruppo_membri" ("user_id");

ALTER TABLE "public"."sottogruppi" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."sottogruppo_membri" ENABLE ROW LEVEL SECURITY;

-- Capo Unità di questa unità, o Capo Gruppo del suo gruppo.
CREATE FUNCTION "public"."posso_gestire_sottogruppi"("p_unit_id" uuid) RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    SELECT EXISTS (
      SELECT 1
      FROM public.units u
      JOIN public.users io ON io.id = auth.uid() AND io.group_id = u.group_id
      WHERE u.id = p_unit_id
        AND EXISTS (
          SELECT 1 FROM public.memberships m
          WHERE m.user_id = auth.uid() AND m.is_active
            AND (
              (m.unit_id = u.id AND m.ruolo >= 'CAPO_UNITA'::public.ruolo_enum)
              OR m.ruolo = 'CAPO_GRUPPO'::public.ruolo_enum
            )
        )
    )
  $$;

REVOKE ALL ON FUNCTION "public"."posso_gestire_sottogruppi"(uuid) FROM PUBLIC, "anon";
GRANT EXECUTE ON FUNCTION "public"."posso_gestire_sottogruppi"(uuid) TO "authenticated", "service_role";

CREATE POLICY "sottogruppi_select" ON "public"."sottogruppi" FOR SELECT TO "authenticated"
  USING ("public"."posso_usare_unita"("unit_id"));

CREATE POLICY "sottogruppi_insert" ON "public"."sottogruppi" FOR INSERT TO "authenticated"
  WITH CHECK ("public"."posso_gestire_sottogruppi"("unit_id"));

CREATE POLICY "sottogruppi_delete" ON "public"."sottogruppi" FOR DELETE TO "authenticated"
  USING ("public"."posso_gestire_sottogruppi"("unit_id"));

CREATE POLICY "sottogruppo_membri_select" ON "public"."sottogruppo_membri" FOR SELECT TO "authenticated"
  USING (EXISTS (
    SELECT 1 FROM "public"."sottogruppi" s
    WHERE s."id" = "sottogruppo_id" AND "public"."posso_usare_unita"(s."unit_id")
  ));

-- Può entrare in un sottogruppo solo chi fa parte dell'unità.
CREATE POLICY "sottogruppo_membri_insert" ON "public"."sottogruppo_membri" FOR INSERT TO "authenticated"
  WITH CHECK (EXISTS (
    SELECT 1 FROM "public"."sottogruppi" s
    JOIN "public"."memberships" m ON m."unit_id" = s."unit_id"
    WHERE s."id" = "sottogruppo_id"
      AND m."user_id" = "sottogruppo_membri"."user_id"
      AND m."is_active"
      AND "public"."posso_gestire_sottogruppi"(s."unit_id")
  ));

CREATE POLICY "sottogruppo_membri_delete" ON "public"."sottogruppo_membri" FOR DELETE TO "authenticated"
  USING (EXISTS (
    SELECT 1 FROM "public"."sottogruppi" s
    WHERE s."id" = "sottogruppo_id" AND "public"."posso_gestire_sottogruppi"(s."unit_id")
  ));

-- Sostituisce i membri di un sottogruppo, creandolo se serve, in un'unica
-- transazione. SECURITY INVOKER: il controllo d'accesso resta nelle policy.
CREATE FUNCTION "public"."salva_membri_sottogruppo"("p_unit_id" uuid, "p_tipo" text, "p_membri" uuid[])
  RETURNS void
  LANGUAGE plpgsql
  SECURITY INVOKER
  SET search_path = public
  AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.sottogruppi (unit_id, tipo) VALUES (p_unit_id, p_tipo)
    ON CONFLICT (unit_id, tipo) DO NOTHING;

  SELECT id INTO v_id FROM public.sottogruppi WHERE unit_id = p_unit_id AND tipo = p_tipo;
  IF v_id IS NULL THEN
    RAISE EXCEPTION 'Sottogruppo non accessibile' USING ERRCODE = '42501';
  END IF;

  DELETE FROM public.sottogruppo_membri
   WHERE sottogruppo_id = v_id AND user_id <> ALL (coalesce(p_membri, '{}'));

  INSERT INTO public.sottogruppo_membri (sottogruppo_id, user_id)
    SELECT v_id, unnest(coalesce(p_membri, '{}'))
    ON CONFLICT DO NOTHING;
END;
$$;

REVOKE ALL ON FUNCTION "public"."salva_membri_sottogruppo"(uuid, text, uuid[]) FROM PUBLIC, "anon";
GRANT EXECUTE ON FUNCTION "public"."salva_membri_sottogruppo"(uuid, text, uuid[]) TO "authenticated", "service_role";

GRANT SELECT, INSERT, DELETE ON TABLE "public"."sottogruppi" TO "authenticated";
GRANT SELECT, INSERT, DELETE ON TABLE "public"."sottogruppo_membri" TO "authenticated";
