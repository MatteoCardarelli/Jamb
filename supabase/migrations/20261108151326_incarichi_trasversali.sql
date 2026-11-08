-- Incarichi trasversali: l'Assistente Ecclesiastico (US32, US33).
--
-- Non è un valore di `ruolo_enum`: le policy confrontano i ruoli con `>=` e una
-- figura esterna alla gerarchia ne altererebbe il significato. Lo nomina il Capo
-- Gruppo e può non avere alcuna unità (decisione dell'utente del 2026-11-08):
-- in quel caso entra nell'area a lui riservata e usa Drive ed eventi della Co.Ca.

CREATE TABLE "public"."incarichi_trasversali" (
  "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  "user_id" uuid NOT NULL REFERENCES "public"."users"("id") ON DELETE CASCADE,
  "group_id" uuid NOT NULL REFERENCES "public"."groups"("id") ON DELETE CASCADE,
  "tipo" text NOT NULL CHECK ("tipo" IN ('assistente_ecclesiastico')),
  "nominato_da" uuid DEFAULT auth.uid() REFERENCES "public"."users"("id") ON DELETE SET NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  UNIQUE ("user_id", "group_id", "tipo")
);

CREATE INDEX "idx_incarichi_group" ON "public"."incarichi_trasversali" ("group_id");

ALTER TABLE "public"."incarichi_trasversali" ENABLE ROW LEVEL SECURITY;

CREATE FUNCTION "public"."is_assistente_ecclesiastico"() RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    SELECT EXISTS (
      SELECT 1
      FROM public.incarichi_trasversali i
      JOIN public.users io ON io.id = i.user_id AND io.group_id = i.group_id
      WHERE i.user_id = auth.uid()
        AND i.tipo = 'assistente_ecclesiastico'
    )
  $$;

REVOKE ALL ON FUNCTION "public"."is_assistente_ecclesiastico"() FROM PUBLIC, "anon";
GRANT EXECUTE ON FUNCTION "public"."is_assistente_ecclesiastico"() TO "authenticated", "service_role";

CREATE POLICY "incarichi_select" ON "public"."incarichi_trasversali" FOR SELECT TO "authenticated"
  USING (
    "user_id" = auth.uid()
    OR ("group_id" = "public"."mio_group_id"()
        AND ("public"."is_capo_gruppo"() OR "public"."sono_capo"()))
  );

CREATE POLICY "incarichi_insert" ON "public"."incarichi_trasversali" FOR INSERT TO "authenticated"
  WITH CHECK (
    "public"."is_capo_gruppo"()
    AND "group_id" = "public"."mio_group_id"()
    AND EXISTS (
      SELECT 1 FROM "public"."users" u
      WHERE u."id" = "incarichi_trasversali"."user_id" AND u."group_id" = "incarichi_trasversali"."group_id"
    )
  );

CREATE POLICY "incarichi_delete" ON "public"."incarichi_trasversali" FOR DELETE TO "authenticated"
  USING ("public"."is_capo_gruppo"() AND "group_id" = "public"."mio_group_id"());

GRANT SELECT, INSERT, DELETE ON TABLE "public"."incarichi_trasversali" TO "authenticated";

-- L'Assistente usa l'unità COCA come i capi del gruppo: Drive ed eventi.
CREATE OR REPLACE FUNCTION "public"."posso_usare_unita"("p_unit_id" uuid) RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    SELECT EXISTS (
      SELECT 1
      FROM public.units u
      JOIN public.users io ON io.id = auth.uid() AND io.group_id = u.group_id
      WHERE u.id = p_unit_id
        AND (
          EXISTS (
            SELECT 1 FROM public.memberships m
            WHERE m.user_id = auth.uid() AND m.is_active
              AND (
                (m.unit_id = u.id AND m.ruolo >= 'AIUTO_CAPO'::public.ruolo_enum)
                OR m.ruolo = 'CAPO_GRUPPO'::public.ruolo_enum
                OR (u.tipo_branca = 'COCA'::public.tipo_branca_enum
                    AND m.ruolo >= 'AIUTO_CAPO'::public.ruolo_enum)
              )
          )
          OR (u.tipo_branca = 'COCA'::public.tipo_branca_enum
              AND EXISTS (
                SELECT 1 FROM public.incarichi_trasversali i
                WHERE i.user_id = auth.uid()
                  AND i.group_id = u.group_id
                  AND i.tipo = 'assistente_ecclesiastico'
              ))
        )
    )
  $$;

DROP POLICY "events_select" ON "public"."events";
CREATE POLICY "events_select" ON "public"."events" FOR SELECT TO "authenticated"
  USING (
    "group_id" = "public"."mio_group_id"()
    AND ("public"."is_capo_gruppo"() OR "public"."sono_capo"() OR "public"."is_assistente_ecclesiastico"())
  );
