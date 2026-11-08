-- Gli eventi di qualsiasi branca sono visibili a tutti i capi del gruppo
-- (segnalazione dell'utente del 2026-11-08): conoscere gli impegni delle altre
-- unità evita sovrapposizioni. Annulla la restrizione in lettura introdotta da
-- `20261108135803_eventi_coca`; le policy di scrittura non cambiano.

DROP POLICY "events_select" ON "public"."events";
CREATE POLICY "events_select" ON "public"."events" FOR SELECT TO "authenticated"
  USING (
    "group_id" = "public"."mio_group_id"()
    AND ("public"."is_capo_gruppo"() OR "public"."sono_capo"())
  );
