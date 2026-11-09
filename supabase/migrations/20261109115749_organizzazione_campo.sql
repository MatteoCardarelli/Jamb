-- Organizzazione di campi e uscite (segnalazione dell'utente del 2026-11-09).
--
-- Un'unità organizza più campi nello stesso anno (invernale, San Giorgio, estivo,
-- uscite): cade il vincolo di un campo per anno e si aggiunge il tipo. Le
-- pattuglie hanno i loro componenti, scelti tra i capi dell'unità, e ogni campo
-- ha una rubrica di contatti telefonici.

ALTER TABLE "public"."campi" DROP CONSTRAINT "campi_unit_id_anno_scout_key";

ALTER TABLE "public"."campi"
  ADD COLUMN "tipo" text NOT NULL DEFAULT 'uscita'
  CHECK ("tipo" IN (
    'campo_invernale', 'san_giorgio', 'campo_estivo', 'vacanze_branco',
    'route_estiva', 'route_invernale', 'uscita'
  ));

CREATE INDEX "idx_campi_unit" ON "public"."campi" ("unit_id");

CREATE TABLE "public"."campo_pattuglia_membri" (
  "pattuglia_id" uuid NOT NULL REFERENCES "public"."campo_pattuglie"("id") ON DELETE CASCADE,
  "user_id" uuid NOT NULL REFERENCES "public"."users"("id") ON DELETE CASCADE,
  PRIMARY KEY ("pattuglia_id", "user_id")
);

CREATE INDEX "idx_campo_pattuglia_membri_user" ON "public"."campo_pattuglia_membri" ("user_id");

CREATE TABLE "public"."campo_contatti" (
  "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  "campo_id" uuid NOT NULL REFERENCES "public"."campi"("id") ON DELETE CASCADE,
  "etichetta" text NOT NULL CHECK (btrim("etichetta") <> ''),
  "telefono" text NOT NULL CHECK (btrim("telefono") <> ''),
  "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

CREATE INDEX "idx_campo_contatti_campo" ON "public"."campo_contatti" ("campo_id");

ALTER TABLE "public"."campo_pattuglia_membri" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."campo_contatti" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "campo_pattuglia_membri_select" ON "public"."campo_pattuglia_membri"
  FOR SELECT TO "authenticated"
  USING (EXISTS (
    SELECT 1 FROM "public"."campo_pattuglie" p
    JOIN "public"."campi" c ON c."id" = p."campo_id"
    WHERE p."id" = "pattuglia_id" AND "public"."posso_usare_unita"(c."unit_id")
  ));

-- Può far parte di una pattuglia solo un capo di quella unità.
CREATE POLICY "campo_pattuglia_membri_insert" ON "public"."campo_pattuglia_membri"
  FOR INSERT TO "authenticated"
  WITH CHECK (EXISTS (
    SELECT 1 FROM "public"."campo_pattuglie" p
    JOIN "public"."campi" c ON c."id" = p."campo_id"
    JOIN "public"."memberships" m ON m."unit_id" = c."unit_id"
    WHERE p."id" = "pattuglia_id"
      AND m."user_id" = "campo_pattuglia_membri"."user_id"
      AND m."is_active"
      AND m."ruolo" >= 'AIUTO_CAPO'::"public"."ruolo_enum"
      AND "public"."posso_usare_unita"(c."unit_id")
  ));

CREATE POLICY "campo_pattuglia_membri_delete" ON "public"."campo_pattuglia_membri"
  FOR DELETE TO "authenticated"
  USING (EXISTS (
    SELECT 1 FROM "public"."campo_pattuglie" p
    JOIN "public"."campi" c ON c."id" = p."campo_id"
    WHERE p."id" = "pattuglia_id" AND "public"."posso_usare_unita"(c."unit_id")
  ));

CREATE POLICY "campo_contatti_tutto" ON "public"."campo_contatti" FOR ALL TO "authenticated"
  USING (EXISTS (
    SELECT 1 FROM "public"."campi" c
    WHERE c."id" = "campo_id" AND "public"."posso_usare_unita"(c."unit_id")
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM "public"."campi" c
    WHERE c."id" = "campo_id" AND "public"."posso_usare_unita"(c."unit_id")
  ));

GRANT SELECT, INSERT, DELETE ON TABLE "public"."campo_pattuglia_membri" TO "authenticated";
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "public"."campo_contatti" TO "authenticated";

-- Sostituisce i componenti di una pattuglia in un'unica transazione.
-- SECURITY INVOKER: il controllo d'accesso resta nelle policy.
CREATE FUNCTION "public"."salva_membri_pattuglia"("p_pattuglia_id" uuid, "p_membri" uuid[])
  RETURNS void
  LANGUAGE plpgsql
  SECURITY INVOKER
  SET search_path = public
  AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.campo_pattuglie WHERE id = p_pattuglia_id) THEN
    RAISE EXCEPTION 'Pattuglia non accessibile' USING ERRCODE = '42501';
  END IF;

  DELETE FROM public.campo_pattuglia_membri
   WHERE pattuglia_id = p_pattuglia_id AND user_id <> ALL (coalesce(p_membri, '{}'));

  INSERT INTO public.campo_pattuglia_membri (pattuglia_id, user_id)
    SELECT p_pattuglia_id, unnest(coalesce(p_membri, '{}'))
    ON CONFLICT DO NOTHING;
END;
$$;

REVOKE ALL ON FUNCTION "public"."salva_membri_pattuglia"(uuid, uuid[]) FROM PUBLIC, "anon";
GRANT EXECUTE ON FUNCTION "public"."salva_membri_pattuglia"(uuid, uuid[]) TO "authenticated", "service_role";
