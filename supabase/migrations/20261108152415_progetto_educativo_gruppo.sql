-- Progetto Educativo di Gruppo (US11, US30).
--
-- Lo scrive il Capo Gruppo; lo leggono i capi del gruppo e l'Assistente
-- Ecclesiastico. Gli obiettivi del Programma d'Unità si possono collegare a un
-- obiettivo del PEG: l'avanzamento si calcola dai loro gradi.

CREATE TABLE "public"."peg" (
  "group_id" uuid PRIMARY KEY REFERENCES "public"."groups"("id") ON DELETE CASCADE,
  "titolo" text NOT NULL DEFAULT '',
  "premessa" text NOT NULL DEFAULT '',
  "updated_at" timestamp with time zone NOT NULL DEFAULT now()
);

CREATE TABLE "public"."peg_obiettivi" (
  "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  "group_id" uuid NOT NULL REFERENCES "public"."groups"("id") ON DELETE CASCADE,
  "titolo" text NOT NULL CHECK (btrim("titolo") <> ''),
  "descrizione" text NOT NULL DEFAULT '',
  "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

CREATE INDEX "idx_peg_obiettivi_group" ON "public"."peg_obiettivi" ("group_id");

ALTER TABLE "public"."obiettivi_educativi"
  ADD COLUMN "peg_obiettivo_id" uuid REFERENCES "public"."peg_obiettivi"("id") ON DELETE SET NULL;

CREATE INDEX "idx_obiettivi_peg" ON "public"."obiettivi_educativi" ("peg_obiettivo_id");

ALTER TABLE "public"."peg" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."peg_obiettivi" ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE
  tabella text;
BEGIN
  FOREACH tabella IN ARRAY ARRAY['peg', 'peg_obiettivi'] LOOP
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR SELECT TO authenticated
         USING (public.posso_leggere_libreria(group_id)
                OR (group_id = public.mio_group_id() AND public.is_assistente_ecclesiastico()))',
      tabella || '_select', tabella);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR INSERT TO authenticated
         WITH CHECK (public.is_capo_gruppo() AND group_id = public.mio_group_id())',
      tabella || '_insert', tabella);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR UPDATE TO authenticated
         USING (public.is_capo_gruppo() AND group_id = public.mio_group_id())
         WITH CHECK (public.is_capo_gruppo() AND group_id = public.mio_group_id())',
      tabella || '_update', tabella);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR DELETE TO authenticated
         USING (public.is_capo_gruppo() AND group_id = public.mio_group_id())',
      tabella || '_delete', tabella);
    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.%I TO authenticated', tabella);
  END LOOP;
END
$$;
