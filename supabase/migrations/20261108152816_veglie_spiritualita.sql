-- Veglie e spunti di spiritualità dell'Assistente Ecclesiastico (US32, US33).
--
-- Le veglie e gli spunti li scrive l'Assistente e li leggono i capi del gruppo.
-- Gli spunti riusano la tabella `pillole` con `tipo = spiritualita` e branca COCA;
-- le pillole del metodo restano a Capo Unità e Capo Gruppo.

CREATE TABLE "public"."veglie" (
  "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  "group_id" uuid NOT NULL REFERENCES "public"."groups"("id") ON DELETE CASCADE,
  "branca" "public"."tipo_branca_enum" NOT NULL,
  "titolo" text NOT NULL CHECK (btrim("titolo") <> ''),
  "struttura" jsonb NOT NULL DEFAULT '[]'::jsonb,
  "autore_id" uuid DEFAULT auth.uid() REFERENCES "public"."users"("id") ON DELETE SET NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now()
);

CREATE INDEX "idx_veglie_group" ON "public"."veglie" ("group_id");

ALTER TABLE "public"."veglie" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "veglie_select" ON "public"."veglie" FOR SELECT TO "authenticated"
  USING (
    "public"."posso_leggere_libreria"("group_id")
    OR ("group_id" = "public"."mio_group_id"() AND "public"."is_assistente_ecclesiastico"())
  );
CREATE POLICY "veglie_insert" ON "public"."veglie" FOR INSERT TO "authenticated"
  WITH CHECK ("group_id" = "public"."mio_group_id"() AND "public"."is_assistente_ecclesiastico"());
CREATE POLICY "veglie_update" ON "public"."veglie" FOR UPDATE TO "authenticated"
  USING ("group_id" = "public"."mio_group_id"() AND "public"."is_assistente_ecclesiastico"())
  WITH CHECK ("group_id" = "public"."mio_group_id"() AND "public"."is_assistente_ecclesiastico"());
CREATE POLICY "veglie_delete" ON "public"."veglie" FOR DELETE TO "authenticated"
  USING ("group_id" = "public"."mio_group_id"() AND "public"."is_assistente_ecclesiastico"());

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "public"."veglie" TO "authenticated";

-- Pillole: ciascun tipo ha i suoi autori.

DROP POLICY "pillole_select" ON "public"."pillole";
CREATE POLICY "pillole_select" ON "public"."pillole" FOR SELECT TO "authenticated"
  USING (
    ("group_id" IS NULL AND "public"."sono_capo"())
    OR "public"."posso_leggere_libreria"("group_id")
    OR ("group_id" = "public"."mio_group_id"() AND "public"."is_assistente_ecclesiastico"())
  );

DROP POLICY "pillole_insert" ON "public"."pillole";
CREATE POLICY "pillole_insert" ON "public"."pillole" FOR INSERT TO "authenticated"
  WITH CHECK (
    "group_id" IS NOT NULL
    AND (
      ("tipo" = 'metodo' AND "public"."posso_scrivere_libreria"("group_id"))
      OR ("tipo" = 'spiritualita' AND "group_id" = "public"."mio_group_id"() AND "public"."is_assistente_ecclesiastico"())
    )
  );

DROP POLICY "pillole_update" ON "public"."pillole";
CREATE POLICY "pillole_update" ON "public"."pillole" FOR UPDATE TO "authenticated"
  USING (
    "group_id" IS NOT NULL
    AND (
      ("tipo" = 'metodo' AND "public"."posso_scrivere_libreria"("group_id"))
      OR ("tipo" = 'spiritualita' AND "group_id" = "public"."mio_group_id"() AND "public"."is_assistente_ecclesiastico"())
    )
  )
  WITH CHECK (
    "group_id" IS NOT NULL
    AND (
      ("tipo" = 'metodo' AND "public"."posso_scrivere_libreria"("group_id"))
      OR ("tipo" = 'spiritualita' AND "group_id" = "public"."mio_group_id"() AND "public"."is_assistente_ecclesiastico"())
    )
  );

DROP POLICY "pillole_delete" ON "public"."pillole";
CREATE POLICY "pillole_delete" ON "public"."pillole" FOR DELETE TO "authenticated"
  USING (
    "group_id" IS NOT NULL
    AND (
      ("tipo" = 'metodo' AND "public"."posso_scrivere_libreria"("group_id"))
      OR ("tipo" = 'spiritualita' AND "group_id" = "public"."mio_group_id"() AND "public"."is_assistente_ecclesiastico"())
    )
  );
