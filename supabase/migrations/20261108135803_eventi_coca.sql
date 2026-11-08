-- Calendario della Comunità Capi (US5, US15).
--
-- I capi non hanno una membership nell'unità COCA: con `ruolo_in_unita` nessuno,
-- tranne il Capo Gruppo, avrebbe potuto creare un evento Co.Ca. Le scritture
-- usano ora `posso_usare_unita`, come il Drive di Co.Ca.: capi dell'unità,
-- Capo Gruppo e, per l'unità COCA, tutti i capi del gruppo.
--
-- La lettura si restringe di conseguenza: il calendario di una branca è visibile
-- solo ai capi di quella branca (US15, decisione dell'utente del 2026-11-08).
-- Gli eventi senza unità restano leggibili da tutti i capi del gruppo.

DROP POLICY "events_select" ON "public"."events";
CREATE POLICY "events_select" ON "public"."events" FOR SELECT TO "authenticated"
  USING (
    "group_id" = "public"."mio_group_id"()
    AND (
      "public"."is_capo_gruppo"()
      OR ("unit_id" IS NULL AND "public"."sono_capo"())
      OR "public"."posso_usare_unita"("unit_id")
    )
  );

DROP POLICY "events_insert" ON "public"."events";
CREATE POLICY "events_insert" ON "public"."events" FOR INSERT TO "authenticated"
  WITH CHECK (
    "group_id" = "public"."mio_group_id"()
    AND ("public"."is_capo_gruppo"() OR "public"."posso_usare_unita"("unit_id"))
  );

DROP POLICY "events_update" ON "public"."events";
CREATE POLICY "events_update" ON "public"."events" FOR UPDATE TO "authenticated"
  USING (
    "group_id" = "public"."mio_group_id"()
    AND ("public"."is_capo_gruppo"() OR "public"."posso_usare_unita"("unit_id"))
  )
  WITH CHECK (
    "group_id" = "public"."mio_group_id"()
    AND ("public"."is_capo_gruppo"() OR "public"."posso_usare_unita"("unit_id"))
  );

DROP POLICY "events_delete" ON "public"."events";
CREATE POLICY "events_delete" ON "public"."events" FOR DELETE TO "authenticated"
  USING (
    "group_id" = "public"."mio_group_id"()
    AND ("public"."is_capo_gruppo"() OR "public"."posso_usare_unita"("unit_id"))
  );
