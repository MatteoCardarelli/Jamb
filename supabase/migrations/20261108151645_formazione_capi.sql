-- Formazione dei capi (US6, US7, US29).
--
-- Ogni capo scrive il proprio iter formativo e il proprio Progetto del Capo. Il
-- Capo Gruppo legge quelli dei capi del gruppo senza modificarli (decisione
-- dell'utente del 2026-11-08).

CREATE FUNCTION "public"."sono_capo_gruppo_di"("p_user_id" uuid) RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    SELECT EXISTS (
      SELECT 1
      FROM public.memberships m
      JOIN public.users io ON io.id = m.user_id
      JOIN public.users altro ON altro.id = p_user_id AND altro.group_id = io.group_id
      WHERE m.user_id = auth.uid()
        AND m.is_active
        AND m.ruolo = 'CAPO_GRUPPO'::public.ruolo_enum
    )
  $$;

REVOKE ALL ON FUNCTION "public"."sono_capo_gruppo_di"(uuid) FROM PUBLIC, "anon";
GRANT EXECUTE ON FUNCTION "public"."sono_capo_gruppo_di"(uuid) TO "authenticated", "service_role";

CREATE TABLE "public"."iter_formativo" (
  "user_id" uuid NOT NULL REFERENCES "public"."users"("id") ON DELETE CASCADE,
  "tappa" text NOT NULL CHECK ("tappa" IN ('CFT', 'CFM', 'CFA', 'NOMINA')),
  "data" date NOT NULL,
  "note" text NOT NULL DEFAULT '',
  PRIMARY KEY ("user_id", "tappa")
);

CREATE TABLE "public"."progetti_capo" (
  "user_id" uuid PRIMARY KEY REFERENCES "public"."users"("id") ON DELETE CASCADE,
  "testo" text NOT NULL DEFAULT '',
  "passi" jsonb NOT NULL DEFAULT '[]'::jsonb,
  "updated_at" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE "public"."iter_formativo" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."progetti_capo" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "iter_select" ON "public"."iter_formativo" FOR SELECT TO "authenticated"
  USING ("user_id" = auth.uid() OR "public"."sono_capo_gruppo_di"("user_id"));
CREATE POLICY "iter_insert" ON "public"."iter_formativo" FOR INSERT TO "authenticated"
  WITH CHECK ("user_id" = auth.uid());
CREATE POLICY "iter_update" ON "public"."iter_formativo" FOR UPDATE TO "authenticated"
  USING ("user_id" = auth.uid()) WITH CHECK ("user_id" = auth.uid());
CREATE POLICY "iter_delete" ON "public"."iter_formativo" FOR DELETE TO "authenticated"
  USING ("user_id" = auth.uid());

CREATE POLICY "progetti_select" ON "public"."progetti_capo" FOR SELECT TO "authenticated"
  USING ("user_id" = auth.uid() OR "public"."sono_capo_gruppo_di"("user_id"));
CREATE POLICY "progetti_insert" ON "public"."progetti_capo" FOR INSERT TO "authenticated"
  WITH CHECK ("user_id" = auth.uid());
CREATE POLICY "progetti_update" ON "public"."progetti_capo" FOR UPDATE TO "authenticated"
  USING ("user_id" = auth.uid()) WITH CHECK ("user_id" = auth.uid());

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "public"."iter_formativo" TO "authenticated";
GRANT SELECT, INSERT, UPDATE ON TABLE "public"."progetti_capo" TO "authenticated";
