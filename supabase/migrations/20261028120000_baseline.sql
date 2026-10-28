


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."brevetto_nome_enum" AS ENUM (
    'Naturalista',
    'Artista',
    'Giornalista',
    'GraficoMultimediale',
    'CittadinoDelMondo',
    'Liturgista',
    'AnimatoreSportivo',
    'GuidaAlpina',
    'ManiAbili',
    'Pioniere',
    'Soccorritore',
    'Sherpa',
    'Trappeur',
    'MaestroDelleTecnologie',
    'EsploratoreDelleAcque'
);


ALTER TYPE "public"."brevetto_nome_enum" OWNER TO "postgres";


CREATE TYPE "public"."categoria_transazione_enum" AS ENUM (
    'materiale',
    'attivita',
    'trasporto',
    'sede',
    'quote',
    'altro'
);


ALTER TYPE "public"."categoria_transazione_enum" OWNER TO "postgres";


CREATE TYPE "public"."ruolo_enum" AS ENUM (
    'RAGAZZO',
    'VICE_CAPO_SQ',
    'CAPO_SQ',
    'AIUTO_CAPO',
    'CAPO_UNITA',
    'CAPO_GRUPPO'
);


ALTER TYPE "public"."ruolo_enum" OWNER TO "postgres";


CREATE TYPE "public"."specialita_nome_enum" AS ENUM (
    'Aereomodellista',
    'Allevatore',
    'Alpinista',
    'AmicoDegliAnimali',
    'AmicoDelQuartiere',
    'Archeologo',
    'Artigiano',
    'ArtistaDiStrada',
    'Astronomo',
    'Atleta',
    'Attore',
    'Battelliere',
    'Boscaiolo',
    'Botanico',
    'Campeggiatore',
    'Canoista',
    'Cantante',
    'CarpentiereNavale',
    'Ciclista',
    'Collezionista',
    'Coltivatore',
    'Corrispondente',
    'CorrispondenteRadio',
    'Cuoco',
    'Danzatore',
    'Disegnatore',
    'Elettricista',
    'Elettronico',
    'EspertoDelComputer',
    'Europeista',
    'Falegname',
    'FaTutto',
    'Folclorista',
    'Fotografo',
    'Giardiniere',
    'Giocattolaio',
    'Grafico',
    'Guida',
    'GuidaMarina',
    'Hebertista',
    'Idraulico',
    'Infermiere',
    'Interprete',
    'LavoratoreInCuoio',
    'MaestroDeiGiochi',
    'MaestroDeiNodi',
    'Meccanico',
    'Modellista',
    'Muratore',
    'Musicista',
    'Naturalista',
    'Nuotatore',
    'Osservatore',
    'OsservatoreMeteo',
    'Pescatore',
    'Pompiere',
    'Redattore',
    'Regista',
    'Sarto',
    'Scenografo',
    'Segnalatore',
    'ServizioDellaParola',
    'ServizioLiturgico',
    'ServizioMissionario',
    'Topografo',
    'Velista'
);


ALTER TYPE "public"."specialita_nome_enum" OWNER TO "postgres";


CREATE TYPE "public"."stato_doc_enum" AS ENUM (
    'nessuno',
    'valido',
    'inScadenza',
    'scaduto'
);


ALTER TYPE "public"."stato_doc_enum" OWNER TO "postgres";


CREATE TYPE "public"."stato_presenza_enum" AS ENUM (
    'INVITATO',
    'CONFERMATO',
    'PRESENTE',
    'ASSENTE'
);


ALTER TYPE "public"."stato_presenza_enum" OWNER TO "postgres";


CREATE TYPE "public"."tappa_sentiero_enum" AS ENUM (
    'nulla',
    'scoperta',
    'competenza',
    'responsabilita'
);


ALTER TYPE "public"."tappa_sentiero_enum" OWNER TO "postgres";


CREATE TYPE "public"."tipo_branca_enum" AS ENUM (
    'LC',
    'EG',
    'RS',
    'COCA'
);


ALTER TYPE "public"."tipo_branca_enum" OWNER TO "postgres";


CREATE TYPE "public"."tipo_evento_enum" AS ENUM (
    'RIUNIONE',
    'USCITA',
    'CAMPO',
    'ROUTE',
    'VEGLIA',
    'EVENTO_GRUPPO'
);


ALTER TYPE "public"."tipo_evento_enum" OWNER TO "postgres";


CREATE TYPE "public"."tipo_post_enum" AS ENUM (
    'AVVISO',
    'CAPITOLO',
    'SERVIZIO'
);


ALTER TYPE "public"."tipo_post_enum" OWNER TO "postgres";


CREATE TYPE "public"."tipo_transazione_enum" AS ENUM (
    'ENTRATA',
    'USCITA'
);


ALTER TYPE "public"."tipo_transazione_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_group_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT group_id FROM public.users WHERE id = auth.uid()
$$;


ALTER FUNCTION "public"."get_my_group_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_squad_ids"() RETURNS "uuid"[]
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT ARRAY_AGG(DISTINCT squad_id)
  FROM public.memberships
  WHERE user_id = auth.uid() AND is_active = TRUE AND squad_id IS NOT NULL
$$;


ALTER FUNCTION "public"."get_my_squad_ids"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_unit_ids"() RETURNS "uuid"[]
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT ARRAY_AGG(DISTINCT unit_id)
  FROM public.memberships
  WHERE user_id = auth.uid() AND is_active = TRUE
$$;


ALTER FUNCTION "public"."get_my_unit_ids"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.users (id, group_id, nome, cognome)
  VALUES (
    NEW.id,
    (NEW.raw_user_meta_data->>'group_id')::UUID,
    COALESCE(NEW.raw_user_meta_data->>'nome', ''),
    COALESCE(NEW.raw_user_meta_data->>'cognome', '')
  );
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_at_least_aiuto_capo"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.memberships
    WHERE user_id = auth.uid() AND is_active = TRUE
      AND ruolo IN ('AIUTO_CAPO','CAPO_UNITA','CAPO_GRUPPO')
  )
$$;


ALTER FUNCTION "public"."is_at_least_aiuto_capo"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_at_least_capo_sq"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.memberships
    WHERE user_id = auth.uid() AND is_active = TRUE
      AND ruolo IN ('CAPO_SQ','AIUTO_CAPO','CAPO_UNITA','CAPO_GRUPPO')
  )
$$;


ALTER FUNCTION "public"."is_at_least_capo_sq"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_at_least_capo_unita"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.memberships
    WHERE user_id = auth.uid() AND is_active = TRUE
      AND ruolo IN ('CAPO_UNITA','CAPO_GRUPPO')
  )
$$;


ALTER FUNCTION "public"."is_at_least_capo_unita"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_capo_della_stessa_unita"("target_user_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.memberships m_capo
    JOIN public.memberships m_target ON m_capo.unit_id = m_target.unit_id
    WHERE m_capo.user_id    = auth.uid()
      AND m_target.user_id  = target_user_id
      AND m_capo.is_active   = TRUE
      AND m_target.is_active = TRUE
      AND m_capo.ruolo IN ('AIUTO_CAPO','CAPO_UNITA')
  )
$$;


ALTER FUNCTION "public"."is_capo_della_stessa_unita"("target_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_capo_gruppo"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM memberships
    WHERE user_id = auth.uid()
      AND ruolo = 'CAPO_GRUPPO'
      AND is_active = true
  );
$$;


ALTER FUNCTION "public"."is_capo_gruppo"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mia_unit_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT unit_id
  FROM memberships
  WHERE user_id = auth.uid()
    AND is_active = true
  LIMIT 1;
$$;


ALTER FUNCTION "public"."mia_unit_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mio_group_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT group_id FROM users WHERE id = auth.uid();
$$;


ALTER FUNCTION "public"."mio_group_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rls_auto_enable"() RETURNS "event_trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'pg_catalog'
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."rls_auto_enable"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ruolo_in_unita"("p_unit_id" "uuid") RETURNS "public"."ruolo_enum"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT ruolo
  FROM memberships
  WHERE user_id = auth.uid()
    AND unit_id = p_unit_id
    AND is_active = true
  LIMIT 1
$$;


ALTER FUNCTION "public"."ruolo_in_unita"("p_unit_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ruolo_in_uscita"("p_unit_id" "uuid") RETURNS "public"."ruolo_enum"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT ruolo
  FROM memberships
  WHERE user_id = auth.uid()
    AND unit_id = p_unit_id
    AND is_active = true
  LIMIT 1
$$;


ALTER FUNCTION "public"."ruolo_in_uscita"("p_unit_id" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."documents" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "unit_id" "uuid",
    "squad_id" "uuid",
    "uploaded_by" "uuid" NOT NULL,
    "parent_id" "uuid",
    "is_cartella" boolean DEFAULT false,
    "titolo" character varying(150) NOT NULL,
    "tipo_file" character varying(10),
    "file_url" character varying,
    "dimensioni" bigint,
    "data_caricamento" timestamp without time zone DEFAULT "now"(),
    "ultima_modifica" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."documents" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."event_attendances" (
    "event_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "stato_presenza" "public"."stato_presenza_enum" DEFAULT 'PRESENTE'::"public"."stato_presenza_enum"
);


ALTER TABLE "public"."event_attendances" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."events" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "group_id" "uuid",
    "unit_id" "uuid",
    "squad_id" "uuid",
    "titolo" character varying(150) NOT NULL,
    "tipo_evento" "public"."tipo_evento_enum" NOT NULL,
    "categorie_tematiche" "jsonb" DEFAULT '[]'::"jsonb",
    "data_inizio" timestamp without time zone NOT NULL,
    "data_fine" timestamp without time zone NOT NULL,
    "luogo" character varying,
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."groups" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "nome" character varying(100) NOT NULL,
    "zona" character varying(50) NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."groups" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."memberships" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "unit_id" "uuid" NOT NULL,
    "squad_id" "uuid",
    "ruolo" "public"."ruolo_enum" NOT NULL,
    "is_active" boolean DEFAULT true,
    "anno_scout" character varying(9) NOT NULL,
    "data_inizio" "date" NOT NULL,
    "data_fine" "date",
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."memberships" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notice_board" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "unit_id" "uuid",
    "squad_id" "uuid",
    "autore_id" "uuid" NOT NULL,
    "tipo_post" "public"."tipo_post_enum" NOT NULL,
    "contenuto" "text" NOT NULL,
    "data_pubblicazione" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."notice_board" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."obiettivi_educativi" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "unit_id" "uuid" NOT NULL,
    "dominio" character varying(100) NOT NULL,
    "descrizione" "text" NOT NULL,
    "grado" smallint DEFAULT 0,
    "diario_di_bordo" "text" DEFAULT ''::"text",
    "anno_scout" character varying(9) NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "colore" bigint,
    "icona" bigint,
    CONSTRAINT "obiettivi_educativi_grado_check" CHECK ((("grado" >= 0) AND ("grado" <= 5)))
);


ALTER TABLE "public"."obiettivi_educativi" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."squads" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "unit_id" "uuid" NOT NULL,
    "nome" character varying(50) NOT NULL,
    "urlo" character varying(255),
    "is_active" boolean DEFAULT true,
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."squads" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."transactions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "group_id" "uuid",
    "unit_id" "uuid",
    "squad_id" "uuid",
    "autore_id" "uuid" NOT NULL,
    "tipo" "public"."tipo_transazione_enum" NOT NULL,
    "importo" numeric(10,2) NOT NULL,
    "titolo" character varying(255) NOT NULL,
    "categoria" "public"."categoria_transazione_enum" DEFAULT 'altro'::"public"."categoria_transazione_enum",
    "note" "text",
    "receipt_url" character varying,
    "data" timestamp without time zone DEFAULT "now"(),
    CONSTRAINT "transactions_owner_check" CHECK (((((("group_id" IS NOT NULL))::integer + (("unit_id" IS NOT NULL))::integer) + (("squad_id" IS NOT NULL))::integer) = 1))
);


ALTER TABLE "public"."transactions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."units" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "group_id" "uuid" NOT NULL,
    "tipo_branca" "public"."tipo_branca_enum" NOT NULL,
    "nome" character varying(100) NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."units" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_brevetti" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "nome" "public"."brevetto_nome_enum" NOT NULL,
    "specialita_collegate" "jsonb" DEFAULT '[]'::"jsonb",
    "prova_finale_superata" boolean DEFAULT false,
    "prova_finale_descrizione" "text",
    "data_conseguimento" "date",
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_brevetti" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_dati_sensibili" (
    "user_id" "uuid" NOT NULL,
    "allergie" "text",
    "note_mediche" "text",
    "contatti_emergenza" "jsonb" DEFAULT '[]'::"jsonb"
);


ALTER TABLE "public"."user_dati_sensibili" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_specialita" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "nome" "public"."specialita_nome_enum" NOT NULL,
    "prove" "jsonb" DEFAULT '[]'::"jsonb",
    "data_conseguimento" "date",
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_specialita" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_tappe" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "tipo" "public"."tappa_sentiero_enum" NOT NULL,
    "impegni" "jsonb" DEFAULT '[]'::"jsonb",
    "anno_scout" character varying(9) NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_tappe" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" NOT NULL,
    "group_id" "uuid" NOT NULL,
    "nome" character varying(50) NOT NULL,
    "cognome" character varying(50) NOT NULL,
    "data_nascita" "date",
    "stato_censimento" "public"."stato_doc_enum" DEFAULT 'nessuno'::"public"."stato_doc_enum",
    "stato_privacy" "public"."stato_doc_enum" DEFAULT 'nessuno'::"public"."stato_doc_enum",
    "stato_medica" "public"."stato_doc_enum" DEFAULT 'nessuno'::"public"."stato_doc_enum",
    "scadenza_privacy" "date",
    "scadenza_medica" "date",
    "is_privacy_signed" boolean DEFAULT false,
    "is_medical_delivered" boolean DEFAULT false,
    "medical_alert" boolean DEFAULT false,
    "storico_scout" "jsonb" DEFAULT '[]'::"jsonb",
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."event_attendances"
    ADD CONSTRAINT "event_attendances_pkey" PRIMARY KEY ("event_id", "user_id");



ALTER TABLE ONLY "public"."events"
    ADD CONSTRAINT "events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."memberships"
    ADD CONSTRAINT "memberships_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notice_board"
    ADD CONSTRAINT "notice_board_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."obiettivi_educativi"
    ADD CONSTRAINT "obiettivi_educativi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."squads"
    ADD CONSTRAINT "squads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."units"
    ADD CONSTRAINT "units_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_brevetti"
    ADD CONSTRAINT "user_brevetti_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_dati_sensibili"
    ADD CONSTRAINT "user_dati_sensibili_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_specialita"
    ADD CONSTRAINT "user_specialita_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_tappe"
    ADD CONSTRAINT "user_tappe_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_attendances_event" ON "public"."event_attendances" USING "btree" ("event_id");



CREATE INDEX "idx_brevetti_user" ON "public"."user_brevetti" USING "btree" ("user_id");



CREATE INDEX "idx_documents_parent" ON "public"."documents" USING "btree" ("parent_id");



CREATE INDEX "idx_documents_unit" ON "public"."documents" USING "btree" ("unit_id");



CREATE INDEX "idx_events_group" ON "public"."events" USING "btree" ("group_id");



CREATE INDEX "idx_events_unit" ON "public"."events" USING "btree" ("unit_id");



CREATE INDEX "idx_memberships_active" ON "public"."memberships" USING "btree" ("user_id", "is_active");



CREATE INDEX "idx_memberships_unit" ON "public"."memberships" USING "btree" ("unit_id");



CREATE INDEX "idx_memberships_user" ON "public"."memberships" USING "btree" ("user_id");



CREATE INDEX "idx_obiettivi_unit" ON "public"."obiettivi_educativi" USING "btree" ("unit_id");



CREATE INDEX "idx_specialita_user" ON "public"."user_specialita" USING "btree" ("user_id");



CREATE INDEX "idx_squads_unit" ON "public"."squads" USING "btree" ("unit_id");



CREATE INDEX "idx_tappe_user" ON "public"."user_tappe" USING "btree" ("user_id");



CREATE INDEX "idx_transactions_group" ON "public"."transactions" USING "btree" ("group_id");



CREATE INDEX "idx_transactions_unit" ON "public"."transactions" USING "btree" ("unit_id");



CREATE INDEX "idx_units_group" ON "public"."units" USING "btree" ("group_id");



CREATE INDEX "idx_users_group" ON "public"."users" USING "btree" ("group_id");



ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."documents"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_squad_id_fkey" FOREIGN KEY ("squad_id") REFERENCES "public"."squads"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."event_attendances"
    ADD CONSTRAINT "event_attendances_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "public"."events"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."event_attendances"
    ADD CONSTRAINT "event_attendances_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."events"
    ADD CONSTRAINT "events_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."events"
    ADD CONSTRAINT "events_squad_id_fkey" FOREIGN KEY ("squad_id") REFERENCES "public"."squads"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."events"
    ADD CONSTRAINT "events_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."memberships"
    ADD CONSTRAINT "memberships_squad_id_fkey" FOREIGN KEY ("squad_id") REFERENCES "public"."squads"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."memberships"
    ADD CONSTRAINT "memberships_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."memberships"
    ADD CONSTRAINT "memberships_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notice_board"
    ADD CONSTRAINT "notice_board_autore_id_fkey" FOREIGN KEY ("autore_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."notice_board"
    ADD CONSTRAINT "notice_board_squad_id_fkey" FOREIGN KEY ("squad_id") REFERENCES "public"."squads"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notice_board"
    ADD CONSTRAINT "notice_board_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."obiettivi_educativi"
    ADD CONSTRAINT "obiettivi_educativi_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."squads"
    ADD CONSTRAINT "squads_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_autore_id_fkey" FOREIGN KEY ("autore_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_squad_id_fkey" FOREIGN KEY ("squad_id") REFERENCES "public"."squads"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."units"
    ADD CONSTRAINT "units_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_brevetti"
    ADD CONSTRAINT "user_brevetti_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_dati_sensibili"
    ADD CONSTRAINT "user_dati_sensibili_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_specialita"
    ADD CONSTRAINT "user_specialita_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_tappe"
    ADD CONSTRAINT "user_tappe_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "attendances_delete" ON "public"."event_attendances" FOR DELETE TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."events" "e"
  WHERE (("e"."id" = "event_attendances"."event_id") AND ("e"."group_id" = "public"."mio_group_id"())))) AND ("public"."is_capo_gruppo"() OR ("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum"))));



CREATE POLICY "attendances_insert" ON "public"."event_attendances" FOR INSERT TO "authenticated" WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."events" "e"
  WHERE (("e"."id" = "event_attendances"."event_id") AND ("e"."group_id" = "public"."mio_group_id"())))) AND ("public"."is_capo_gruppo"() OR ("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum"))));



CREATE POLICY "attendances_select" ON "public"."event_attendances" FOR SELECT TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."events" "e"
  WHERE (("e"."id" = "event_attendances"."event_id") AND ("e"."group_id" = "public"."mio_group_id"())))) AND ("public"."is_capo_gruppo"() OR ("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum"))));



CREATE POLICY "attendances_update" ON "public"."event_attendances" FOR UPDATE TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."events" "e"
  WHERE (("e"."id" = "event_attendances"."event_id") AND ("e"."group_id" = "public"."mio_group_id"())))) AND ("public"."is_capo_gruppo"() OR ("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum")))) WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."events" "e"
  WHERE (("e"."id" = "event_attendances"."event_id") AND ("e"."group_id" = "public"."mio_group_id"())))) AND ("public"."is_capo_gruppo"() OR ("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum"))));



CREATE POLICY "brevetti_delete" ON "public"."user_brevetti" FOR DELETE USING ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_brevetti"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_brevetti"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "brevetti_insert" ON "public"."user_brevetti" FOR INSERT TO "authenticated" WITH CHECK ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_brevetti"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_brevetti"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "brevetti_select" ON "public"."user_brevetti" FOR SELECT TO "authenticated" USING ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_brevetti"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_brevetti"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "brevetti_update" ON "public"."user_brevetti" FOR UPDATE TO "authenticated" USING ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_brevetti"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_brevetti"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true))))))) WITH CHECK ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_brevetti"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_brevetti"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "dati_sensibili_insert" ON "public"."user_dati_sensibili" FOR INSERT TO "authenticated" WITH CHECK ((("user_id" = "auth"."uid"()) OR ("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_dati_sensibili"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_dati_sensibili"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "dati_sensibili_select" ON "public"."user_dati_sensibili" FOR SELECT TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR ("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_dati_sensibili"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_dati_sensibili"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "dati_sensibili_update" ON "public"."user_dati_sensibili" FOR UPDATE TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR ("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_dati_sensibili"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_dati_sensibili"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true))))))) WITH CHECK ((("user_id" = "auth"."uid"()) OR ("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_dati_sensibili"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_dati_sensibili"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



ALTER TABLE "public"."documents" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "documents_delete" ON "public"."documents" FOR DELETE TO "authenticated" USING ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));



CREATE POLICY "documents_insert" ON "public"."documents" FOR INSERT TO "authenticated" WITH CHECK ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));



CREATE POLICY "documents_select" ON "public"."documents" FOR SELECT TO "authenticated" USING ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));



CREATE POLICY "documents_update" ON "public"."documents" FOR UPDATE TO "authenticated" USING ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum"))) WITH CHECK ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));



ALTER TABLE "public"."event_attendances" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."events" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "events_delete" ON "public"."events" FOR DELETE TO "authenticated" USING ((("group_id" = "public"."mio_group_id"()) AND ("public"."is_capo_gruppo"() OR ("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum"))));



CREATE POLICY "events_insert" ON "public"."events" FOR INSERT TO "authenticated" WITH CHECK ((("group_id" = "public"."mio_group_id"()) AND ("public"."is_capo_gruppo"() OR ("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum"))));



CREATE POLICY "events_select" ON "public"."events" FOR SELECT TO "authenticated" USING ((("group_id" = "public"."mio_group_id"()) AND ("public"."is_capo_gruppo"() OR ("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum"))));



CREATE POLICY "events_update" ON "public"."events" FOR UPDATE TO "authenticated" USING ((("group_id" = "public"."mio_group_id"()) AND ("public"."is_capo_gruppo"() OR ("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum")))) WITH CHECK ((("group_id" = "public"."mio_group_id"()) AND ("public"."is_capo_gruppo"() OR ("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum"))));



ALTER TABLE "public"."groups" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "groups_select" ON "public"."groups" FOR SELECT TO "authenticated" USING (("id" = "public"."mio_group_id"()));



CREATE POLICY "groups_update" ON "public"."groups" FOR UPDATE TO "authenticated" USING (("public"."is_capo_gruppo"() AND ("id" = "public"."mio_group_id"()))) WITH CHECK (("public"."is_capo_gruppo"() AND ("id" = "public"."mio_group_id"())));



ALTER TABLE "public"."memberships" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "memberships_insert" ON "public"."memberships" FOR INSERT TO "authenticated" WITH CHECK ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR (("public"."ruolo_in_unita"("unit_id") >= 'CAPO_UNITA'::"public"."ruolo_enum") AND ("ruolo" = ANY (ARRAY['RAGAZZO'::"public"."ruolo_enum", 'VICE_CAPO_SQ'::"public"."ruolo_enum", 'CAPO_SQ'::"public"."ruolo_enum"])))));



CREATE POLICY "memberships_select" ON "public"."memberships" FOR SELECT TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR ("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND ("unit_id" = "public"."mia_unit_id"()))));



CREATE POLICY "memberships_update" ON "public"."memberships" FOR UPDATE TO "authenticated" USING ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'CAPO_UNITA'::"public"."ruolo_enum") AND ("unit_id" = "public"."mia_unit_id"())))) WITH CHECK ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'CAPO_UNITA'::"public"."ruolo_enum") AND ("unit_id" = "public"."mia_unit_id"()))));



ALTER TABLE "public"."notice_board" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "notice_delete" ON "public"."notice_board" FOR DELETE TO "authenticated" USING ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));



CREATE POLICY "notice_insert" ON "public"."notice_board" FOR INSERT TO "authenticated" WITH CHECK ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));



CREATE POLICY "notice_select" ON "public"."notice_board" FOR SELECT TO "authenticated" USING ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));



CREATE POLICY "notice_update" ON "public"."notice_board" FOR UPDATE TO "authenticated" USING ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum"))) WITH CHECK ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));



CREATE POLICY "obiettivi_delete" ON "public"."obiettivi_educativi" FOR DELETE TO "authenticated" USING ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));



ALTER TABLE "public"."obiettivi_educativi" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "obiettivi_insert" ON "public"."obiettivi_educativi" FOR INSERT TO "authenticated" WITH CHECK ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));



CREATE POLICY "obiettivi_select" ON "public"."obiettivi_educativi" FOR SELECT TO "authenticated" USING ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));



CREATE POLICY "obiettivi_update" ON "public"."obiettivi_educativi" FOR UPDATE TO "authenticated" USING ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum"))) WITH CHECK ((("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")));



CREATE POLICY "specialita_delete" ON "public"."user_specialita" FOR DELETE USING ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_specialita"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_specialita"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "specialita_insert" ON "public"."user_specialita" FOR INSERT TO "authenticated" WITH CHECK ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_specialita"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_specialita"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "specialita_select" ON "public"."user_specialita" FOR SELECT TO "authenticated" USING ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_specialita"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_specialita"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "specialita_update" ON "public"."user_specialita" FOR UPDATE TO "authenticated" USING ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_specialita"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_specialita"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true))))))) WITH CHECK ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_specialita"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_specialita"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



ALTER TABLE "public"."squads" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "squads_insert" ON "public"."squads" FOR INSERT TO "authenticated" WITH CHECK ((("public"."ruolo_in_unita"("unit_id") >= 'CAPO_UNITA'::"public"."ruolo_enum") OR "public"."is_capo_gruppo"()));



CREATE POLICY "squads_select" ON "public"."squads" FOR SELECT TO "authenticated" USING ((("public"."ruolo_in_unita"("unit_id") IS NOT NULL) OR "public"."is_capo_gruppo"()));



CREATE POLICY "squads_update" ON "public"."squads" FOR UPDATE TO "authenticated" USING ((("public"."ruolo_in_unita"("unit_id") >= 'CAPO_UNITA'::"public"."ruolo_enum") OR "public"."is_capo_gruppo"())) WITH CHECK ((("public"."ruolo_in_unita"("unit_id") >= 'CAPO_UNITA'::"public"."ruolo_enum") OR "public"."is_capo_gruppo"()));



CREATE POLICY "tappe_delete" ON "public"."user_tappe" FOR DELETE USING ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_tappe"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_tappe"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "tappe_insert" ON "public"."user_tappe" FOR INSERT TO "authenticated" WITH CHECK ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_tappe"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_tappe"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "tappe_select" ON "public"."user_tappe" FOR SELECT TO "authenticated" USING ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_tappe"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_tappe"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "tappe_update" ON "public"."user_tappe" FOR UPDATE TO "authenticated" USING ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_tappe"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_tappe"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true))))))) WITH CHECK ((("public"."is_capo_gruppo"() AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "user_tappe"."user_id") AND ("users"."group_id" = "public"."mio_group_id"()))))) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "user_tappe"."user_id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



ALTER TABLE "public"."transactions" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "transactions_delete" ON "public"."transactions" FOR DELETE TO "authenticated" USING (((("group_id" IS NOT NULL) AND "public"."is_capo_gruppo"() AND ("group_id" = "public"."mio_group_id"())) OR (("unit_id" IS NOT NULL) AND (("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")))));



CREATE POLICY "transactions_insert" ON "public"."transactions" FOR INSERT TO "authenticated" WITH CHECK (((("group_id" IS NOT NULL) AND "public"."is_capo_gruppo"() AND ("group_id" = "public"."mio_group_id"())) OR (("unit_id" IS NOT NULL) AND (("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")))));



CREATE POLICY "transactions_select" ON "public"."transactions" FOR SELECT TO "authenticated" USING (((("group_id" IS NOT NULL) AND "public"."is_capo_gruppo"() AND ("group_id" = "public"."mio_group_id"())) OR (("unit_id" IS NOT NULL) AND (("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")))));



CREATE POLICY "transactions_update" ON "public"."transactions" FOR UPDATE TO "authenticated" USING (((("group_id" IS NOT NULL) AND "public"."is_capo_gruppo"() AND ("group_id" = "public"."mio_group_id"())) OR (("unit_id" IS NOT NULL) AND (("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum"))))) WITH CHECK (((("group_id" IS NOT NULL) AND "public"."is_capo_gruppo"() AND ("group_id" = "public"."mio_group_id"())) OR (("unit_id" IS NOT NULL) AND (("public"."is_capo_gruppo"() AND ("unit_id" IN ( SELECT "units"."id"
   FROM "public"."units"
  WHERE ("units"."group_id" = "public"."mio_group_id"())))) OR ("public"."ruolo_in_unita"("unit_id") >= 'AIUTO_CAPO'::"public"."ruolo_enum")))));



ALTER TABLE "public"."units" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "units_insert" ON "public"."units" FOR INSERT TO "authenticated" WITH CHECK ("public"."is_capo_gruppo"());



CREATE POLICY "units_select" ON "public"."units" FOR SELECT TO "authenticated" USING (("group_id" = "public"."mio_group_id"()));



CREATE POLICY "units_update" ON "public"."units" FOR UPDATE TO "authenticated" USING (("public"."is_capo_gruppo"() OR ("public"."ruolo_in_unita"("id") >= 'CAPO_UNITA'::"public"."ruolo_enum"))) WITH CHECK (("public"."is_capo_gruppo"() OR ("public"."ruolo_in_unita"("id") >= 'CAPO_UNITA'::"public"."ruolo_enum")));



ALTER TABLE "public"."user_brevetti" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_dati_sensibili" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_specialita" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_tappe" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "users_select" ON "public"."users" FOR SELECT TO "authenticated" USING ((("id" = "auth"."uid"()) OR ("public"."is_capo_gruppo"() AND ("group_id" = "public"."mio_group_id"())) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "users"."id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));



CREATE POLICY "users_update" ON "public"."users" FOR UPDATE TO "authenticated" USING ((("id" = "auth"."uid"()) OR ("public"."is_capo_gruppo"() AND ("group_id" = "public"."mio_group_id"())) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "users"."id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true))))))) WITH CHECK ((("id" = "auth"."uid"()) OR ("public"."is_capo_gruppo"() AND ("group_id" = "public"."mio_group_id"())) OR (("public"."ruolo_in_unita"("public"."mia_unit_id"()) >= 'AIUTO_CAPO'::"public"."ruolo_enum") AND (EXISTS ( SELECT 1
   FROM "public"."memberships"
  WHERE (("memberships"."user_id" = "users"."id") AND ("memberships"."unit_id" = "public"."mia_unit_id"()) AND ("memberships"."is_active" = true)))))));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";






















































































































































GRANT ALL ON FUNCTION "public"."get_my_group_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_group_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_group_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_squad_ids"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_squad_ids"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_squad_ids"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_unit_ids"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_unit_ids"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_unit_ids"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_at_least_aiuto_capo"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_at_least_aiuto_capo"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_at_least_aiuto_capo"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_at_least_capo_sq"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_at_least_capo_sq"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_at_least_capo_sq"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_at_least_capo_unita"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_at_least_capo_unita"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_at_least_capo_unita"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_capo_della_stessa_unita"("target_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_capo_della_stessa_unita"("target_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_capo_della_stessa_unita"("target_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_capo_gruppo"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_capo_gruppo"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_capo_gruppo"() TO "service_role";



GRANT ALL ON FUNCTION "public"."mia_unit_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."mia_unit_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."mia_unit_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."mio_group_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."mio_group_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."mio_group_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "anon";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "service_role";



GRANT ALL ON FUNCTION "public"."ruolo_in_unita"("p_unit_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."ruolo_in_unita"("p_unit_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ruolo_in_unita"("p_unit_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."ruolo_in_uscita"("p_unit_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."ruolo_in_uscita"("p_unit_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ruolo_in_uscita"("p_unit_id" "uuid") TO "service_role";


















GRANT ALL ON TABLE "public"."documents" TO "anon";
GRANT ALL ON TABLE "public"."documents" TO "authenticated";
GRANT ALL ON TABLE "public"."documents" TO "service_role";



GRANT ALL ON TABLE "public"."event_attendances" TO "anon";
GRANT ALL ON TABLE "public"."event_attendances" TO "authenticated";
GRANT ALL ON TABLE "public"."event_attendances" TO "service_role";



GRANT ALL ON TABLE "public"."events" TO "anon";
GRANT ALL ON TABLE "public"."events" TO "authenticated";
GRANT ALL ON TABLE "public"."events" TO "service_role";



GRANT ALL ON TABLE "public"."groups" TO "anon";
GRANT ALL ON TABLE "public"."groups" TO "authenticated";
GRANT ALL ON TABLE "public"."groups" TO "service_role";



GRANT ALL ON TABLE "public"."memberships" TO "anon";
GRANT ALL ON TABLE "public"."memberships" TO "authenticated";
GRANT ALL ON TABLE "public"."memberships" TO "service_role";



GRANT ALL ON TABLE "public"."notice_board" TO "anon";
GRANT ALL ON TABLE "public"."notice_board" TO "authenticated";
GRANT ALL ON TABLE "public"."notice_board" TO "service_role";



GRANT ALL ON TABLE "public"."obiettivi_educativi" TO "anon";
GRANT ALL ON TABLE "public"."obiettivi_educativi" TO "authenticated";
GRANT ALL ON TABLE "public"."obiettivi_educativi" TO "service_role";



GRANT ALL ON TABLE "public"."squads" TO "anon";
GRANT ALL ON TABLE "public"."squads" TO "authenticated";
GRANT ALL ON TABLE "public"."squads" TO "service_role";



GRANT ALL ON TABLE "public"."transactions" TO "anon";
GRANT ALL ON TABLE "public"."transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions" TO "service_role";



GRANT ALL ON TABLE "public"."units" TO "anon";
GRANT ALL ON TABLE "public"."units" TO "authenticated";
GRANT ALL ON TABLE "public"."units" TO "service_role";



GRANT ALL ON TABLE "public"."user_brevetti" TO "anon";
GRANT ALL ON TABLE "public"."user_brevetti" TO "authenticated";
GRANT ALL ON TABLE "public"."user_brevetti" TO "service_role";



GRANT ALL ON TABLE "public"."user_dati_sensibili" TO "anon";
GRANT ALL ON TABLE "public"."user_dati_sensibili" TO "authenticated";
GRANT ALL ON TABLE "public"."user_dati_sensibili" TO "service_role";



GRANT ALL ON TABLE "public"."user_specialita" TO "anon";
GRANT ALL ON TABLE "public"."user_specialita" TO "authenticated";
GRANT ALL ON TABLE "public"."user_specialita" TO "service_role";



GRANT ALL ON TABLE "public"."user_tappe" TO "anon";
GRANT ALL ON TABLE "public"."user_tappe" TO "authenticated";
GRANT ALL ON TABLE "public"."user_tappe" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";





































-- Trigger su auth.users: non incluso dal dump perché lo schema auth è
-- gestito dalla piattaforma. Popola public.users alla creazione di un utente.
CREATE OR REPLACE TRIGGER "on_auth_user_created" AFTER INSERT ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_user"();
