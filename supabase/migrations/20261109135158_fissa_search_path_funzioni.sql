-- Le ultime funzioni SECURITY DEFINER nate senza search_path, come le altre
-- dal 2026-11-07: search_path vuoto e tabelle qualificate. Così chi le chiama
-- non può far risolvere i nomi su oggetti propri. Il comportamento non cambia.

CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET search_path = ''
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

CREATE OR REPLACE FUNCTION "public"."is_capo_gruppo"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET search_path = ''
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.memberships
    WHERE user_id = auth.uid()
      AND ruolo = 'CAPO_GRUPPO'
      AND is_active = true
  );
$$;

CREATE OR REPLACE FUNCTION "public"."mio_group_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET search_path = ''
    AS $$
  SELECT group_id FROM public.users WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION "public"."ruolo_in_unita"("p_unit_id" "uuid") RETURNS "public"."ruolo_enum"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET search_path = ''
    AS $$
  SELECT ruolo
  FROM public.memberships
  WHERE user_id = auth.uid()
    AND unit_id = p_unit_id
    AND is_active = true
  LIMIT 1
$$;
