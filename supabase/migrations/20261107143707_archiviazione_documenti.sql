-- Archiviazione dei file (Fase 3.1): bucket privati, policy sullo storage,
-- documenti organizzati per sezione e Drive della Comunità Capi.
--
-- Decisioni dell'utente (2026-11-07):
-- - Drive Co.Ca.: un'unità COCA per gruppo, accessibile a tutti i capi del
--   gruppo (AIUTO_CAPO o più in una qualunque unità) tramite policy, senza
--   membership esplicite.
-- - Metodo e Statuto e Modulistica Uscite: libreria di gruppo; leggono tutti
--   i capi, caricano e cancellano Capo Unità e Capo Gruppo.
--
-- 1. Unità COCA, una per gruppo (solo struttura: nessun dato personale).
-- 2. documents: gruppo obbligatorio, sezione (drive di un'unità o libreria
--    di gruppo), date con fuso orario, autore dalla sessione.
-- 3. Funzioni di supporto (SECURITY DEFINER, search_path vuoto, tabelle
--    qualificate) per documenti e storage.
-- 4. Policy di documents riscritte per sezione; la cartella padre deve
--    essere della stessa sezione e dello stesso proprietario.
-- 5. Bucket privati `documenti` e `ricevute` con limiti di dimensione e tipi.
-- 6. Policy su storage.objects: il percorso è {gruppo}/{unità}/{file} (o
--    {gruppo}/libreria/{file}) e l'accesso segue quello dei documenti.

-- 1. Unità della Comunità Capi

INSERT INTO "public"."units" ("group_id", "tipo_branca", "nome")
SELECT "g"."id", 'COCA', 'Comunità Capi'
FROM "public"."groups" "g"
WHERE NOT EXISTS (
  SELECT 1 FROM "public"."units" "u"
  WHERE "u"."group_id" = "g"."id" AND "u"."tipo_branca" = 'COCA'
);

-- 2. documents

ALTER TABLE "public"."documents"
  ADD COLUMN "group_id" uuid REFERENCES "public"."groups"("id") ON DELETE CASCADE,
  ADD COLUMN "sezione" text NOT NULL DEFAULT 'drive';

UPDATE "public"."documents" "d"
SET "group_id" = "u"."group_id"
FROM "public"."units" "u"
WHERE "u"."id" = "d"."unit_id";

ALTER TABLE "public"."documents"
  ALTER COLUMN "group_id" SET NOT NULL,
  ALTER COLUMN "uploaded_by" SET DEFAULT auth.uid(),
  ALTER COLUMN "is_cartella" SET NOT NULL,
  ADD CONSTRAINT "documents_sezione_check"
    CHECK ("sezione" IN ('drive', 'metodo_statuto', 'modulistica')),
  -- Il drive appartiene a un'unità, la libreria al solo gruppo.
  ADD CONSTRAINT "documents_proprietario_check"
    CHECK (("sezione" = 'drive') = ("unit_id" IS NOT NULL)),
  ADD CONSTRAINT "documents_titolo_check" CHECK (btrim("titolo") <> '');

ALTER TABLE "public"."documents"
  ALTER COLUMN "data_caricamento" TYPE timestamp with time zone
    USING "data_caricamento" AT TIME ZONE 'UTC';
ALTER TABLE "public"."documents"
  ALTER COLUMN "ultima_modifica" TYPE timestamp with time zone
    USING "ultima_modifica" AT TIME ZONE 'UTC';
ALTER TABLE "public"."documents"
  ALTER COLUMN "data_caricamento" SET NOT NULL,
  ALTER COLUMN "ultima_modifica" SET NOT NULL;

COMMENT ON COLUMN "public"."documents"."file_url" IS
  'Percorso del file nel bucket `documenti` (non un URL: si apre con un URL firmato)';
COMMENT ON COLUMN "public"."transactions"."receipt_url" IS
  'Percorso della foto nel bucket `ricevute` (non un URL: si apre con un URL firmato)';

CREATE INDEX "idx_documents_group_sezione" ON "public"."documents" ("group_id", "sezione");

-- 3. Funzioni di supporto

-- Drive di un'unità: capi dell'unità, Capo Gruppo, e per l'unità COCA tutti
-- i capi del gruppo.
CREATE FUNCTION "public"."posso_usare_unita"("p_unit_id" uuid) RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    SELECT EXISTS (
      SELECT 1
      FROM public.units u
      JOIN public.users io ON io.id = auth.uid() AND io.group_id = u.group_id
      WHERE u.id = p_unit_id
        AND EXISTS (
          SELECT 1 FROM public.memberships m
          WHERE m.user_id = auth.uid() AND m.is_active
            AND (
              (m.unit_id = u.id AND m.ruolo >= 'AIUTO_CAPO'::public.ruolo_enum)
              OR m.ruolo = 'CAPO_GRUPPO'::public.ruolo_enum
              OR (u.tipo_branca = 'COCA'::public.tipo_branca_enum
                  AND m.ruolo >= 'AIUTO_CAPO'::public.ruolo_enum)
            )
        )
    )
  $$;

-- Libreria di gruppo: la leggono tutti i capi del gruppo.
CREATE FUNCTION "public"."posso_leggere_libreria"("p_group_id" uuid) RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    SELECT EXISTS (
      SELECT 1
      FROM public.users io
      JOIN public.memberships m ON m.user_id = io.id AND m.is_active
      WHERE io.id = auth.uid()
        AND io.group_id = p_group_id
        AND m.ruolo >= 'AIUTO_CAPO'::public.ruolo_enum
    )
  $$;

-- Libreria di gruppo: la modificano Capo Unità e Capo Gruppo.
CREATE FUNCTION "public"."posso_scrivere_libreria"("p_group_id" uuid) RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    SELECT EXISTS (
      SELECT 1
      FROM public.users io
      JOIN public.memberships m ON m.user_id = io.id AND m.is_active
      WHERE io.id = auth.uid()
        AND io.group_id = p_group_id
        AND m.ruolo >= 'CAPO_UNITA'::public.ruolo_enum
    )
  $$;

-- Un documento si può modificare se è nel drive di un'unità utilizzabile
-- (dello stesso gruppo) o nella libreria e si è Capo Unità o più.
CREATE FUNCTION "public"."posso_scrivere_documento"("p_sezione" text, "p_unit_id" uuid, "p_group_id" uuid)
  RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    SELECT CASE
      WHEN p_sezione = 'drive' THEN
        public.posso_usare_unita(p_unit_id)
        AND EXISTS (SELECT 1 FROM public.units u WHERE u.id = p_unit_id AND u.group_id = p_group_id)
      ELSE public.posso_scrivere_libreria(p_group_id)
    END
  $$;

CREATE FUNCTION "public"."posso_leggere_documento"("p_sezione" text, "p_unit_id" uuid, "p_group_id" uuid)
  RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    SELECT CASE
      WHEN p_sezione = 'drive' THEN public.posso_usare_unita(p_unit_id)
      ELSE public.posso_leggere_libreria(p_group_id)
    END
  $$;

-- Storage: il primo livello del percorso è il gruppo, il secondo l'unità o
-- «libreria». Percorsi di forma diversa non sono accessibili.
CREATE FUNCTION "public"."accesso_file_documenti"("p_nome" text, "p_scrittura" boolean)
  RETURNS boolean
  LANGUAGE plpgsql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    DECLARE
      parti text[] := storage.foldername(p_nome);
      gruppo uuid := (SELECT group_id FROM public.users WHERE id = auth.uid());
    BEGIN
      IF coalesce(array_length(parti, 1), 0) <> 2 OR gruppo IS NULL OR parti[1] <> gruppo::text THEN
        RETURN false;
      END IF;
      IF parti[2] = 'libreria' THEN
        RETURN CASE WHEN p_scrittura
          THEN public.posso_scrivere_libreria(gruppo)
          ELSE public.posso_leggere_libreria(gruppo) END;
      END IF;
      RETURN EXISTS (
        SELECT 1 FROM public.units u
        WHERE u.id::text = parti[2] AND u.group_id = gruppo
          AND public.posso_usare_unita(u.id)
      );
    END
  $$;

CREATE FUNCTION "public"."accesso_file_ricevute"("p_nome" text) RETURNS boolean
  LANGUAGE plpgsql STABLE SECURITY DEFINER
  SET search_path = ''
  AS $$
    DECLARE
      parti text[] := storage.foldername(p_nome);
      gruppo uuid := (SELECT group_id FROM public.users WHERE id = auth.uid());
    BEGIN
      IF coalesce(array_length(parti, 1), 0) <> 2 OR gruppo IS NULL OR parti[1] <> gruppo::text THEN
        RETURN false;
      END IF;
      RETURN EXISTS (
        SELECT 1 FROM public.units u
        WHERE u.id::text = parti[2] AND u.group_id = gruppo
          AND public.posso_usare_unita(u.id)
      );
    END
  $$;

REVOKE ALL ON FUNCTION "public"."posso_usare_unita"(uuid) FROM PUBLIC, "anon";
REVOKE ALL ON FUNCTION "public"."posso_leggere_libreria"(uuid) FROM PUBLIC, "anon";
REVOKE ALL ON FUNCTION "public"."posso_scrivere_libreria"(uuid) FROM PUBLIC, "anon";
REVOKE ALL ON FUNCTION "public"."posso_scrivere_documento"(text, uuid, uuid) FROM PUBLIC, "anon";
REVOKE ALL ON FUNCTION "public"."posso_leggere_documento"(text, uuid, uuid) FROM PUBLIC, "anon";
REVOKE ALL ON FUNCTION "public"."accesso_file_documenti"(text, boolean) FROM PUBLIC, "anon";
REVOKE ALL ON FUNCTION "public"."accesso_file_ricevute"(text) FROM PUBLIC, "anon";
GRANT EXECUTE ON FUNCTION "public"."posso_usare_unita"(uuid) TO "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "public"."posso_leggere_libreria"(uuid) TO "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "public"."posso_scrivere_libreria"(uuid) TO "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "public"."posso_scrivere_documento"(text, uuid, uuid) TO "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "public"."posso_leggere_documento"(text, uuid, uuid) TO "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "public"."accesso_file_documenti"(text, boolean) TO "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "public"."accesso_file_ricevute"(text) TO "authenticated", "service_role";

-- 4. Policy di documents

DROP POLICY "documents_select" ON "public"."documents";
DROP POLICY "documents_insert" ON "public"."documents";
DROP POLICY "documents_update" ON "public"."documents";
DROP POLICY "documents_delete" ON "public"."documents";

CREATE POLICY "documents_select" ON "public"."documents" FOR SELECT TO "authenticated"
  USING ("public"."posso_leggere_documento"("sezione", "unit_id", "group_id"));

-- La sottoquery sulla cartella padre passa dalle policy di lettura.
CREATE POLICY "documents_insert" ON "public"."documents" FOR INSERT TO "authenticated"
  WITH CHECK (
    "public"."posso_scrivere_documento"("sezione", "unit_id", "group_id")
    AND "uploaded_by" = auth.uid()
    AND ("parent_id" IS NULL OR EXISTS ( SELECT 1 FROM "public"."documents" "p"
      WHERE "p"."id" = "documents"."parent_id"
        AND "p"."is_cartella"
        AND "p"."sezione" = "documents"."sezione"
        AND "p"."group_id" = "documents"."group_id"
        AND "p"."unit_id" IS NOT DISTINCT FROM "documents"."unit_id"))
  );

CREATE POLICY "documents_update" ON "public"."documents" FOR UPDATE TO "authenticated"
  USING ("public"."posso_scrivere_documento"("sezione", "unit_id", "group_id"))
  WITH CHECK (
    "public"."posso_scrivere_documento"("sezione", "unit_id", "group_id")
    AND ("parent_id" IS NULL OR EXISTS ( SELECT 1 FROM "public"."documents" "p"
      WHERE "p"."id" = "documents"."parent_id"
        AND "p"."is_cartella"
        AND "p"."sezione" = "documents"."sezione"
        AND "p"."group_id" = "documents"."group_id"
        AND "p"."unit_id" IS NOT DISTINCT FROM "documents"."unit_id"))
  );

CREATE POLICY "documents_delete" ON "public"."documents" FOR DELETE TO "authenticated"
  USING ("public"."posso_scrivere_documento"("sezione", "unit_id", "group_id"));

-- 5. Bucket

INSERT INTO "storage"."buckets" ("id", "name", "public", "file_size_limit", "allowed_mime_types")
VALUES
  ('documenti', 'documenti', false, 20971520, ARRAY[
    'application/pdf',
    'image/jpeg', 'image/png', 'image/webp', 'image/heic',
    'text/plain', 'text/csv',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.oasis.opendocument.text',
    'application/vnd.oasis.opendocument.spreadsheet',
    'application/vnd.oasis.opendocument.presentation',
    'application/zip'
  ]),
  ('ricevute', 'ricevute', false, 10485760, ARRAY[
    'image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf'
  ])
ON CONFLICT ("id") DO NOTHING;

-- 6. Policy sullo storage

CREATE POLICY "documenti_select" ON "storage"."objects" FOR SELECT TO "authenticated"
  USING ("bucket_id" = 'documenti' AND "public"."accesso_file_documenti"("name", false));
CREATE POLICY "documenti_insert" ON "storage"."objects" FOR INSERT TO "authenticated"
  WITH CHECK ("bucket_id" = 'documenti' AND "public"."accesso_file_documenti"("name", true));
CREATE POLICY "documenti_update" ON "storage"."objects" FOR UPDATE TO "authenticated"
  USING ("bucket_id" = 'documenti' AND "public"."accesso_file_documenti"("name", true))
  WITH CHECK ("bucket_id" = 'documenti' AND "public"."accesso_file_documenti"("name", true));
CREATE POLICY "documenti_delete" ON "storage"."objects" FOR DELETE TO "authenticated"
  USING ("bucket_id" = 'documenti' AND "public"."accesso_file_documenti"("name", true));

CREATE POLICY "ricevute_select" ON "storage"."objects" FOR SELECT TO "authenticated"
  USING ("bucket_id" = 'ricevute' AND "public"."accesso_file_ricevute"("name"));
CREATE POLICY "ricevute_insert" ON "storage"."objects" FOR INSERT TO "authenticated"
  WITH CHECK ("bucket_id" = 'ricevute' AND "public"."accesso_file_ricevute"("name"));
CREATE POLICY "ricevute_update" ON "storage"."objects" FOR UPDATE TO "authenticated"
  USING ("bucket_id" = 'ricevute' AND "public"."accesso_file_ricevute"("name"))
  WITH CHECK ("bucket_id" = 'ricevute' AND "public"."accesso_file_ricevute"("name"));
CREATE POLICY "ricevute_delete" ON "storage"."objects" FOR DELETE TO "authenticated"
  USING ("bucket_id" = 'ricevute' AND "public"."accesso_file_ricevute"("name"));
