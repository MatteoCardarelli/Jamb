-- Policy sull'unità della riga invece che su mia_unit_id() (Fase 2.3, US27).
--
-- mia_unit_id() restituiva la «prima» membership attiva dell'utente
-- (LIMIT 1 senza ordinamento): per un capo con più unità il database
-- ragionava sempre su una sola, qualunque unità scegliesse nell'app.
-- Decisione dell'utente (2026-11-07): riscrivere le policy, non limitare il
-- selettore al Capo Gruppo.
--
-- - Ragazzi e loro dati (users, user_dati_sensibili, user_tappe,
--   user_specialita, user_brevetti): accessibili se il ragazzo ha una
--   membership attiva in un'unità dove chi legge è AIUTO_CAPO o più
--   (sono_capo_di). Restano invariati l'accesso ai propri dati e quello del
--   Capo Gruppo.
-- - memberships: ruolo nell'unità della riga.
-- - events: lettura invariata (tutto il gruppo, per chi è capo in almeno
--   un'unità: servirà al calendario di gruppo della Fase 4); scrittura solo
--   negli eventi delle unità dove si è AIUTO_CAPO o più.
-- - mia_unit_id() non è più usata da nulla e viene eliminata.
--
-- Le funzioni nuove fissano search_path e qualificano le tabelle: sono
-- SECURITY DEFINER per leggere memberships senza ripassare dalle sue RLS.

-- Funzioni di supporto

CREATE FUNCTION "public"."sono_capo_di"("p_user_id" uuid) RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    SELECT EXISTS (
      SELECT 1
      FROM public.memberships ragazzo
      JOIN public.memberships capo ON capo.unit_id = ragazzo.unit_id
      WHERE ragazzo.user_id = p_user_id
        AND ragazzo.is_active
        AND capo.user_id = auth.uid()
        AND capo.is_active
        AND capo.ruolo >= 'AIUTO_CAPO'::public.ruolo_enum
    )
  $$;

COMMENT ON FUNCTION "public"."sono_capo_di"(uuid) IS
  'true se p_user_id ha una membership attiva in un''unità dove l''utente loggato è AIUTO_CAPO o più';

CREATE FUNCTION "public"."sono_capo"() RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    SELECT EXISTS (
      SELECT 1 FROM public.memberships
      WHERE user_id = auth.uid()
        AND is_active
        AND ruolo >= 'AIUTO_CAPO'::public.ruolo_enum
    )
  $$;

COMMENT ON FUNCTION "public"."sono_capo"() IS
  'true se l''utente loggato è AIUTO_CAPO o più in almeno un''unità';

REVOKE ALL ON FUNCTION "public"."sono_capo_di"(uuid) FROM PUBLIC, "anon";
REVOKE ALL ON FUNCTION "public"."sono_capo"() FROM PUBLIC, "anon";
GRANT EXECUTE ON FUNCTION "public"."sono_capo_di"(uuid) TO "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "public"."sono_capo"() TO "authenticated", "service_role";

-- users

DROP POLICY "users_select" ON "public"."users";
CREATE POLICY "users_select" ON "public"."users" FOR SELECT TO "authenticated"
  USING (
    "id" = auth.uid()
    OR ("public"."is_capo_gruppo"() AND "group_id" = "public"."mio_group_id"())
    OR "public"."sono_capo_di"("id")
  );

DROP POLICY "users_update" ON "public"."users";
CREATE POLICY "users_update" ON "public"."users" FOR UPDATE TO "authenticated"
  USING (
    "id" = auth.uid()
    OR ("public"."is_capo_gruppo"() AND "group_id" = "public"."mio_group_id"())
    OR "public"."sono_capo_di"("id")
  )
  WITH CHECK (
    "id" = auth.uid()
    OR ("public"."is_capo_gruppo"() AND "group_id" = "public"."mio_group_id"())
    OR "public"."sono_capo_di"("id")
  );

-- user_dati_sensibili

DROP POLICY "dati_sensibili_select" ON "public"."user_dati_sensibili";
CREATE POLICY "dati_sensibili_select" ON "public"."user_dati_sensibili" FOR SELECT TO "authenticated"
  USING (
    "user_id" = auth.uid()
    OR ("public"."is_capo_gruppo"() AND EXISTS ( SELECT 1 FROM "public"."users"
          WHERE "users"."id" = "user_dati_sensibili"."user_id"
            AND "users"."group_id" = "public"."mio_group_id"()))
    OR "public"."sono_capo_di"("user_id")
  );

DROP POLICY "dati_sensibili_insert" ON "public"."user_dati_sensibili";
CREATE POLICY "dati_sensibili_insert" ON "public"."user_dati_sensibili" FOR INSERT TO "authenticated"
  WITH CHECK (
    "user_id" = auth.uid()
    OR ("public"."is_capo_gruppo"() AND EXISTS ( SELECT 1 FROM "public"."users"
          WHERE "users"."id" = "user_dati_sensibili"."user_id"
            AND "users"."group_id" = "public"."mio_group_id"()))
    OR "public"."sono_capo_di"("user_id")
  );

DROP POLICY "dati_sensibili_update" ON "public"."user_dati_sensibili";
CREATE POLICY "dati_sensibili_update" ON "public"."user_dati_sensibili" FOR UPDATE TO "authenticated"
  USING (
    "user_id" = auth.uid()
    OR ("public"."is_capo_gruppo"() AND EXISTS ( SELECT 1 FROM "public"."users"
          WHERE "users"."id" = "user_dati_sensibili"."user_id"
            AND "users"."group_id" = "public"."mio_group_id"()))
    OR "public"."sono_capo_di"("user_id")
  )
  WITH CHECK (
    "user_id" = auth.uid()
    OR ("public"."is_capo_gruppo"() AND EXISTS ( SELECT 1 FROM "public"."users"
          WHERE "users"."id" = "user_dati_sensibili"."user_id"
            AND "users"."group_id" = "public"."mio_group_id"()))
    OR "public"."sono_capo_di"("user_id")
  );

-- Progressione: stessa condizione per tappe, specialità e brevetti e per
-- tutte le operazioni.

DO $$
DECLARE
  tabella text;
  prefisso text;
  condizione text;
BEGIN
  FOREACH tabella IN ARRAY ARRAY['user_tappe', 'user_specialita', 'user_brevetti'] LOOP
    prefisso := replace(tabella, 'user_', '');
    condizione := format(
      '("public"."is_capo_gruppo"() AND EXISTS ( SELECT 1 FROM "public"."users"
          WHERE "users"."id" = %1$I."user_id"
            AND "users"."group_id" = "public"."mio_group_id"()))
       OR "public"."sono_capo_di"(%1$I."user_id")',
      tabella);

    EXECUTE format('DROP POLICY %I ON public.%I', prefisso || '_select', tabella);
    EXECUTE format('DROP POLICY %I ON public.%I', prefisso || '_insert', tabella);
    EXECUTE format('DROP POLICY %I ON public.%I', prefisso || '_update', tabella);
    EXECUTE format('DROP POLICY %I ON public.%I', prefisso || '_delete', tabella);

    EXECUTE format('CREATE POLICY %I ON public.%I FOR SELECT TO authenticated USING (%s)',
      prefisso || '_select', tabella, condizione);
    EXECUTE format('CREATE POLICY %I ON public.%I FOR INSERT TO authenticated WITH CHECK (%s)',
      prefisso || '_insert', tabella, condizione);
    EXECUTE format('CREATE POLICY %I ON public.%I FOR UPDATE TO authenticated USING (%s) WITH CHECK (%s)',
      prefisso || '_update', tabella, condizione, condizione);
    EXECUTE format('CREATE POLICY %I ON public.%I FOR DELETE TO authenticated USING (%s)',
      prefisso || '_delete', tabella, condizione);
  END LOOP;
END
$$;

-- memberships

DROP POLICY "memberships_select" ON "public"."memberships";
CREATE POLICY "memberships_select" ON "public"."memberships" FOR SELECT TO "authenticated"
  USING (
    "user_id" = auth.uid()
    OR ("public"."is_capo_gruppo"() AND "unit_id" IN ( SELECT "units"."id" FROM "public"."units"
          WHERE "units"."group_id" = "public"."mio_group_id"()))
    OR "public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum"
  );

DROP POLICY "memberships_update" ON "public"."memberships";
CREATE POLICY "memberships_update" ON "public"."memberships" FOR UPDATE TO "authenticated"
  USING (
    ("public"."is_capo_gruppo"() AND "unit_id" IN ( SELECT "units"."id" FROM "public"."units"
          WHERE "units"."group_id" = "public"."mio_group_id"()))
    OR "public"."ruolo_in_unita"("unit_id") >= 'CAPO_UNITA'::"public"."ruolo_enum"
  )
  WITH CHECK (
    ("public"."is_capo_gruppo"() AND "unit_id" IN ( SELECT "units"."id" FROM "public"."units"
          WHERE "units"."group_id" = "public"."mio_group_id"()))
    OR "public"."ruolo_in_unita"("unit_id") >= 'CAPO_UNITA'::"public"."ruolo_enum"
  );

-- events

DROP POLICY "events_select" ON "public"."events";
CREATE POLICY "events_select" ON "public"."events" FOR SELECT TO "authenticated"
  USING (
    "group_id" = "public"."mio_group_id"()
    AND ("public"."is_capo_gruppo"() OR "public"."sono_capo"())
  );

DROP POLICY "events_insert" ON "public"."events";
CREATE POLICY "events_insert" ON "public"."events" FOR INSERT TO "authenticated"
  WITH CHECK (
    "group_id" = "public"."mio_group_id"()
    AND ("public"."is_capo_gruppo"()
         OR "public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")
  );

DROP POLICY "events_update" ON "public"."events";
CREATE POLICY "events_update" ON "public"."events" FOR UPDATE TO "authenticated"
  USING (
    "group_id" = "public"."mio_group_id"()
    AND ("public"."is_capo_gruppo"()
         OR "public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")
  )
  WITH CHECK (
    "group_id" = "public"."mio_group_id"()
    AND ("public"."is_capo_gruppo"()
         OR "public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")
  );

DROP POLICY "events_delete" ON "public"."events";
CREATE POLICY "events_delete" ON "public"."events" FOR DELETE TO "authenticated"
  USING (
    "group_id" = "public"."mio_group_id"()
    AND ("public"."is_capo_gruppo"()
         OR "public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")
  );

-- mia_unit_id() non è più usata

DROP FUNCTION "public"."mia_unit_id"();
