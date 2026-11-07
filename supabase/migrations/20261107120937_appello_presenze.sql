-- Appello delle presenze agli eventi (US16, Fase 2.2).
--
-- 1. Nuovo stato GIUSTIFICATO: un'assenza avvisata non va contata come le
--    altre nella segnalazione delle assenze ripetute. INVITATO e CONFERMATO
--    restano per le adesioni, che l'app non usa ancora.
-- 2. Lo stato è obbligatorio (la tabella è vuota): una riga senza stato non
--    direbbe nulla.
-- 3. Le policy valutano il ruolo nell'unità dell'evento invece che in
--    mia_unit_id() (la «prima» membership, vedi nota della Fase 2.3), e in
--    scrittura esigono che la persona appartenga, o sia appartenuta,
--    all'unità dell'evento: prima si poteva registrare chiunque del gruppo.
--    Gli eventi senza unità (di gruppo) restano al solo Capo Gruppo.
-- 4. Indice per lo storico di un ragazzo (la chiave primaria parte dall'evento).

-- 1. e 2.

ALTER TYPE "public"."stato_presenza_enum" ADD VALUE IF NOT EXISTS 'GIUSTIFICATO';

ALTER TABLE "public"."event_attendances"
  ALTER COLUMN "stato_presenza" SET NOT NULL;

-- 3. Policy

DROP POLICY "attendances_select" ON "public"."event_attendances";
DROP POLICY "attendances_insert" ON "public"."event_attendances";
DROP POLICY "attendances_update" ON "public"."event_attendances";
DROP POLICY "attendances_delete" ON "public"."event_attendances";

CREATE POLICY "attendances_select" ON "public"."event_attendances" FOR SELECT TO "authenticated"
  USING (EXISTS ( SELECT 1 FROM "public"."events" "e"
    WHERE "e"."id" = "event_attendances"."event_id"
      AND "e"."group_id" = "public"."mio_group_id"()
      AND ("public"."is_capo_gruppo"()
           OR "public"."ruolo_in_unita"("e"."unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));

CREATE POLICY "attendances_insert" ON "public"."event_attendances" FOR INSERT TO "authenticated"
  WITH CHECK (EXISTS ( SELECT 1 FROM "public"."events" "e"
    WHERE "e"."id" = "event_attendances"."event_id"
      AND "e"."group_id" = "public"."mio_group_id"()
      AND ("public"."is_capo_gruppo"()
           OR "public"."ruolo_in_unita"("e"."unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")
      AND EXISTS ( SELECT 1 FROM "public"."memberships" "m"
        WHERE "m"."user_id" = "event_attendances"."user_id"
          AND "m"."unit_id" = "e"."unit_id")));

CREATE POLICY "attendances_update" ON "public"."event_attendances" FOR UPDATE TO "authenticated"
  USING (EXISTS ( SELECT 1 FROM "public"."events" "e"
    WHERE "e"."id" = "event_attendances"."event_id"
      AND "e"."group_id" = "public"."mio_group_id"()
      AND ("public"."is_capo_gruppo"()
           OR "public"."ruolo_in_unita"("e"."unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")))
  WITH CHECK (EXISTS ( SELECT 1 FROM "public"."events" "e"
    WHERE "e"."id" = "event_attendances"."event_id"
      AND "e"."group_id" = "public"."mio_group_id"()
      AND ("public"."is_capo_gruppo"()
           OR "public"."ruolo_in_unita"("e"."unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")
      AND EXISTS ( SELECT 1 FROM "public"."memberships" "m"
        WHERE "m"."user_id" = "event_attendances"."user_id"
          AND "m"."unit_id" = "e"."unit_id")));

CREATE POLICY "attendances_delete" ON "public"."event_attendances" FOR DELETE TO "authenticated"
  USING (EXISTS ( SELECT 1 FROM "public"."events" "e"
    WHERE "e"."id" = "event_attendances"."event_id"
      AND "e"."group_id" = "public"."mio_group_id"()
      AND ("public"."is_capo_gruppo"()
           OR "public"."ruolo_in_unita"("e"."unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));

-- 4. Indice

CREATE INDEX "idx_attendances_user" ON "public"."event_attendances" ("user_id");
