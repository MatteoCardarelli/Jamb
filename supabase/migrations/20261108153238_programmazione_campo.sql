-- Programmazione del campo (US18), in versione ridotta (decisione dell'utente
-- del 2026-11-08): un campo per unità e anno scout, pattuglie dello Staff e
-- compiti con stato, condivisi da tutti i capi dell'unità.

CREATE TABLE "public"."campi" (
  "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  "unit_id" uuid NOT NULL REFERENCES "public"."units"("id") ON DELETE CASCADE,
  "anno_scout" character varying(9) NOT NULL,
  "titolo" text NOT NULL CHECK (btrim("titolo") <> ''),
  "luogo" text NOT NULL DEFAULT '',
  "data_inizio" date,
  "data_fine" date,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  UNIQUE ("unit_id", "anno_scout"),
  CHECK ("data_fine" IS NULL OR "data_inizio" IS NULL OR "data_fine" >= "data_inizio")
);

CREATE TABLE "public"."campo_pattuglie" (
  "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  "campo_id" uuid NOT NULL REFERENCES "public"."campi"("id") ON DELETE CASCADE,
  "nome" text NOT NULL CHECK (btrim("nome") <> ''),
  "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

CREATE TABLE "public"."campo_compiti" (
  "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  "pattuglia_id" uuid NOT NULL REFERENCES "public"."campo_pattuglie"("id") ON DELETE CASCADE,
  "titolo" text NOT NULL CHECK (btrim("titolo") <> ''),
  "stato" text NOT NULL DEFAULT 'da_fare' CHECK ("stato" IN ('da_fare', 'in_corso', 'fatto')),
  "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

CREATE INDEX "idx_campo_pattuglie_campo" ON "public"."campo_pattuglie" ("campo_id");
CREATE INDEX "idx_campo_compiti_pattuglia" ON "public"."campo_compiti" ("pattuglia_id");

ALTER TABLE "public"."campi" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."campo_pattuglie" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."campo_compiti" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "campi_tutto" ON "public"."campi" FOR ALL TO "authenticated"
  USING ("public"."posso_usare_unita"("unit_id"))
  WITH CHECK ("public"."posso_usare_unita"("unit_id"));

CREATE POLICY "campo_pattuglie_tutto" ON "public"."campo_pattuglie" FOR ALL TO "authenticated"
  USING (EXISTS (
    SELECT 1 FROM "public"."campi" c
    WHERE c."id" = "campo_id" AND "public"."posso_usare_unita"(c."unit_id")
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM "public"."campi" c
    WHERE c."id" = "campo_id" AND "public"."posso_usare_unita"(c."unit_id")
  ));

CREATE POLICY "campo_compiti_tutto" ON "public"."campo_compiti" FOR ALL TO "authenticated"
  USING (EXISTS (
    SELECT 1 FROM "public"."campo_pattuglie" p
    JOIN "public"."campi" c ON c."id" = p."campo_id"
    WHERE p."id" = "pattuglia_id" AND "public"."posso_usare_unita"(c."unit_id")
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM "public"."campo_pattuglie" p
    JOIN "public"."campi" c ON c."id" = p."campo_id"
    WHERE p."id" = "pattuglia_id" AND "public"."posso_usare_unita"(c."unit_id")
  ));

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "public"."campi" TO "authenticated";
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "public"."campo_pattuglie" TO "authenticated";
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "public"."campo_compiti" TO "authenticated";
