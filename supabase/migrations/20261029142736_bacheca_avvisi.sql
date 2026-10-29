-- Bacheca avvisi (US25, Fase 2.1).
--
-- 1. notice_board diventa utilizzabile dall'app: oggetto dell'avviso
--    (titolo, come nel mockup), unità obbligatoria (le policy la usano),
--    data di pubblicazione con fuso orario, autore preso dalla sessione.
--    La tabella è vuota, quindi i vincoli NOT NULL non toccano dati esistenti.
-- 2. Le policy di scrittura restano ad AIUTO_CAPO (decisione del 2026-10-29),
--    ma in più l'autore deve essere chi scrive e la squadriglia destinataria
--    deve appartenere all'unità dell'avviso.
-- 3. notice_reads registra chi ha letto quale avviso, per il conteggio dei
--    non letti: ognuno vede e scrive solo le proprie letture, e solo per
--    avvisi che può leggere.

-- 1. Colonne di notice_board

ALTER TABLE "public"."notice_board"
  ADD COLUMN "titolo" text NOT NULL,
  ADD CONSTRAINT "notice_board_titolo_check" CHECK (btrim("titolo") <> ''),
  ADD CONSTRAINT "notice_board_contenuto_check" CHECK (btrim("contenuto") <> ''),
  ALTER COLUMN "unit_id" SET NOT NULL,
  ALTER COLUMN "autore_id" SET DEFAULT auth.uid(),
  ALTER COLUMN "data_pubblicazione" TYPE timestamp with time zone
    USING "data_pubblicazione" AT TIME ZONE 'UTC',
  ALTER COLUMN "data_pubblicazione" SET NOT NULL;

CREATE INDEX "notice_board_unit_id_data_idx"
  ON "public"."notice_board" ("unit_id", "data_pubblicazione" DESC);

-- 2. Policy di scrittura

DROP POLICY "notice_insert" ON "public"."notice_board";
CREATE POLICY "notice_insert" ON "public"."notice_board" FOR INSERT TO "authenticated"
  WITH CHECK (
    (("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
       FROM "public"."units"
      WHERE ("units"."group_id" = "public"."mio_group_id"()))))
     OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum"))
    AND "autore_id" = auth.uid()
    AND ("squad_id" IS NULL OR EXISTS ( SELECT 1
       FROM "public"."squads"
      WHERE "squads"."id" = "notice_board"."squad_id"
        AND "squads"."unit_id" = "notice_board"."unit_id"))
  );

DROP POLICY "notice_update" ON "public"."notice_board";
CREATE POLICY "notice_update" ON "public"."notice_board" FOR UPDATE TO "authenticated"
  USING (
    ("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
       FROM "public"."units"
      WHERE ("units"."group_id" = "public"."mio_group_id"()))))
    OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")
  )
  WITH CHECK (
    (("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
       FROM "public"."units"
      WHERE ("units"."group_id" = "public"."mio_group_id"()))))
     OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum"))
    AND ("squad_id" IS NULL OR EXISTS ( SELECT 1
       FROM "public"."squads"
      WHERE "squads"."id" = "notice_board"."squad_id"
        AND "squads"."unit_id" = "notice_board"."unit_id"))
  );

-- 3. Letture degli avvisi

CREATE TABLE "public"."notice_reads" (
  "user_id" uuid NOT NULL DEFAULT auth.uid()
    REFERENCES "public"."users"("id") ON DELETE CASCADE,
  "notice_id" uuid NOT NULL
    REFERENCES "public"."notice_board"("id") ON DELETE CASCADE,
  "letto_il" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("user_id", "notice_id")
);

ALTER TABLE "public"."notice_reads" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notice_reads_select" ON "public"."notice_reads" FOR SELECT TO "authenticated"
  USING ("user_id" = auth.uid());

-- La sottoquery su notice_board passa dalle sue policy: si può segnare
-- come letto solo un avviso che si può leggere.
CREATE POLICY "notice_reads_insert" ON "public"."notice_reads" FOR INSERT TO "authenticated"
  WITH CHECK (
    "user_id" = auth.uid()
    AND EXISTS ( SELECT 1 FROM "public"."notice_board"
      WHERE "notice_board"."id" = "notice_reads"."notice_id")
  );

REVOKE ALL ON TABLE "public"."notice_reads" FROM "anon";
GRANT SELECT, INSERT ON TABLE "public"."notice_reads" TO "authenticated";
GRANT ALL ON TABLE "public"."notice_reads" TO "service_role";
