-- Isolamento tra gruppi (piano, sezione 9-bis, GP.0).
--
-- Con un solo gruppo nel database non cambia nulla. Dal secondo gruppo in poi
-- queste regole avrebbero permesso a un Capo Gruppo di creare o modificare
-- unità e squadriglie di altri gruppi, e a chiunque di spostarsi in un altro
-- gruppo cambiando il proprio profilo (e da Capo Gruppo leggerne i dati).

-- 1. Persona e unità dello stesso gruppo.
--    SECURITY DEFINER: chi inserisce una membership spesso non può ancora
--    leggere il profilo della persona (lo vedrà solo dopo, tramite la membership).
CREATE FUNCTION "public"."stesso_gruppo"("p_user_id" "uuid", "p_unit_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET search_path = ''
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.users u
    JOIN public.units un ON un.group_id = u.group_id
    WHERE u.id = p_user_id AND un.id = p_unit_id
  );
$$;

REVOKE EXECUTE ON FUNCTION "public"."stesso_gruppo"("uuid", "uuid") FROM PUBLIC, "anon";
GRANT EXECUTE ON FUNCTION "public"."stesso_gruppo"("uuid", "uuid") TO "authenticated", "service_role";

-- 2. Unità: il Capo Gruppo crea e modifica solo quelle del proprio gruppo, e
--    nessuno sposta un'unità in un altro gruppo.
DROP POLICY "units_insert" ON "public"."units";
CREATE POLICY "units_insert" ON "public"."units" FOR INSERT TO "authenticated"
  WITH CHECK ("public"."is_capo_gruppo"() AND "group_id" = "public"."mio_group_id"());

DROP POLICY "units_update" ON "public"."units";
CREATE POLICY "units_update" ON "public"."units" FOR UPDATE TO "authenticated"
  USING (
    ("public"."is_capo_gruppo"() AND "group_id" = "public"."mio_group_id"())
    OR "public"."ruolo_in_unita"("id") >= 'CAPO_UNITA'::"public"."ruolo_enum"
  )
  WITH CHECK (
    "group_id" = "public"."mio_group_id"()
    AND ("public"."is_capo_gruppo"() OR "public"."ruolo_in_unita"("id") >= 'CAPO_UNITA'::"public"."ruolo_enum")
  );

-- 3. Squadriglie: il ramo del Capo Gruppo vale solo per le unità del suo gruppo.
DROP POLICY "squads_select" ON "public"."squads";
CREATE POLICY "squads_select" ON "public"."squads" FOR SELECT TO "authenticated"
  USING (
    "public"."ruolo_in_unita"("unit_id") IS NOT NULL
    OR ("public"."is_capo_gruppo"() AND "unit_id" IN (
          SELECT "units"."id" FROM "public"."units" WHERE "units"."group_id" = "public"."mio_group_id"()))
  );

DROP POLICY "squads_insert" ON "public"."squads";
CREATE POLICY "squads_insert" ON "public"."squads" FOR INSERT TO "authenticated"
  WITH CHECK (
    "public"."ruolo_in_unita"("unit_id") >= 'CAPO_UNITA'::"public"."ruolo_enum"
    OR ("public"."is_capo_gruppo"() AND "unit_id" IN (
          SELECT "units"."id" FROM "public"."units" WHERE "units"."group_id" = "public"."mio_group_id"()))
  );

DROP POLICY "squads_update" ON "public"."squads";
CREATE POLICY "squads_update" ON "public"."squads" FOR UPDATE TO "authenticated"
  USING (
    "public"."ruolo_in_unita"("unit_id") >= 'CAPO_UNITA'::"public"."ruolo_enum"
    OR ("public"."is_capo_gruppo"() AND "unit_id" IN (
          SELECT "units"."id" FROM "public"."units" WHERE "units"."group_id" = "public"."mio_group_id"()))
  )
  WITH CHECK (
    "public"."ruolo_in_unita"("unit_id") >= 'CAPO_UNITA'::"public"."ruolo_enum"
    OR ("public"."is_capo_gruppo"() AND "unit_id" IN (
          SELECT "units"."id" FROM "public"."units" WHERE "units"."group_id" = "public"."mio_group_id"()))
  );

-- 4. Membership: la persona deve appartenere al gruppo dell'unità.
DROP POLICY "memberships_insert" ON "public"."memberships";
CREATE POLICY "memberships_insert" ON "public"."memberships" FOR INSERT TO "authenticated"
  WITH CHECK (
    "public"."stesso_gruppo"("user_id", "unit_id")
    AND (
      ("public"."is_capo_gruppo"() AND "unit_id" IN (
          SELECT "units"."id" FROM "public"."units" WHERE "units"."group_id" = "public"."mio_group_id"()))
      OR ("public"."ruolo_in_unita"("unit_id") >= 'CAPO_UNITA'::"public"."ruolo_enum"
          AND "ruolo" = ANY (ARRAY['RAGAZZO'::"public"."ruolo_enum", 'VICE_CAPO_SQ'::"public"."ruolo_enum", 'CAPO_SQ'::"public"."ruolo_enum"]))
    )
  );

DROP POLICY "memberships_update" ON "public"."memberships";
CREATE POLICY "memberships_update" ON "public"."memberships" FOR UPDATE TO "authenticated"
  USING (
    ("public"."is_capo_gruppo"() AND "unit_id" IN (
        SELECT "units"."id" FROM "public"."units" WHERE "units"."group_id" = "public"."mio_group_id"()))
    OR "public"."ruolo_in_unita"("unit_id") >= 'CAPO_UNITA'::"public"."ruolo_enum"
  )
  WITH CHECK (
    "public"."stesso_gruppo"("user_id", "unit_id")
    AND (
      ("public"."is_capo_gruppo"() AND "unit_id" IN (
          SELECT "units"."id" FROM "public"."units" WHERE "units"."group_id" = "public"."mio_group_id"()))
      OR "public"."ruolo_in_unita"("unit_id") >= 'CAPO_UNITA'::"public"."ruolo_enum"
    )
  );

-- 5. Profilo: identificativo e gruppo non si cambiano dall'app. La policy
--    `users_update` lascia modificare il proprio profilo e, senza questo
--    controllo, anche il gruppo. Restano possibili le correzioni fatte senza
--    utente (service_role, console).
CREATE FUNCTION "public"."blocca_cambio_gruppo"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET search_path = ''
    AS $$
BEGIN
  IF auth.uid() IS NOT NULL
     AND (NEW.id IS DISTINCT FROM OLD.id OR NEW.group_id IS DISTINCT FROM OLD.group_id) THEN
    RAISE EXCEPTION 'Il gruppo di una persona non si cambia dall''app'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER "users_gruppo_immutabile"
  BEFORE UPDATE OF "id", "group_id" ON "public"."users"
  FOR EACH ROW EXECUTE FUNCTION "public"."blocca_cambio_gruppo"();

-- 6. Una sola membership attiva per persona e unità: `salva_ragazzo` e la
--    sessione la cercano come unica. Oggi non ci sono doppioni.
CREATE UNIQUE INDEX "memberships_una_attiva_per_unita"
  ON "public"."memberships" ("user_id", "unit_id") WHERE "is_active";
