-- Schede senza account (piano, sezione 9-bis, GP.1).
--
-- Prima la scheda, poi, se serve, l'account: una persona (capo o ragazzo) è
-- una riga di `users` creata da un capo, e l'account si aggancia dopo con lo
-- stesso id (`auth.admin.createUser` accetta l'id). Per chi ha un account
-- resta vero `users.id = auth.uid()`, quindi nessuna policy esistente cambia.
-- Con il codice attuale dell'app non cambia nulla: l'app non crea account.

-- 1. La scheda non dipende più dall'account.
ALTER TABLE "public"."users" DROP CONSTRAINT "users_id_fkey";
ALTER TABLE "public"."users" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."users" ADD COLUMN "account_attivo" boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN "public"."users"."account_attivo" IS
  'Vero se la persona ha un account (riga in auth.users con lo stesso id). Lo scrivono solo i trigger.';
UPDATE "public"."users" u SET "account_attivo" = true
  WHERE EXISTS (SELECT 1 FROM auth.users a WHERE a.id = u.id);

-- 2. Un account nuovo si aggancia a una scheda esistente; senza scheda viene
--    rifiutato. Così la registrazione libera non crea profili, e i metadati
--    (che sceglie chi si registra) non decidono più il gruppo.
CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET search_path = ''
    AS $$
BEGIN
  UPDATE public.users SET account_attivo = true WHERE id = NEW.id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Nessuna scheda per questo account: gli account si creano solo a partire da una scheda'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

-- 3. Se si elimina un account la scheda resta, con progressione e presenze.
CREATE FUNCTION "public"."account_eliminato"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET search_path = ''
    AS $$
BEGIN
  UPDATE public.users SET account_attivo = false WHERE id = OLD.id;
  RETURN OLD;
END;
$$;

REVOKE EXECUTE ON FUNCTION "public"."account_eliminato"() FROM PUBLIC, "anon", "authenticated";

CREATE TRIGGER "on_auth_user_deleted"
  AFTER DELETE ON "auth"."users"
  FOR EACH ROW EXECUTE FUNCTION "public"."account_eliminato"();

-- 4. Come gruppo e id, anche `account_attivo` non si cambia dall'app: lo
--    scrivono solo i trigger qui sopra (che girano senza utente).
CREATE OR REPLACE FUNCTION "public"."blocca_cambio_gruppo"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET search_path = ''
    AS $$
BEGIN
  IF auth.uid() IS NOT NULL
     AND (NEW.id IS DISTINCT FROM OLD.id
          OR NEW.group_id IS DISTINCT FROM OLD.group_id
          OR NEW.account_attivo IS DISTINCT FROM OLD.account_attivo) THEN
    RAISE EXCEPTION 'Questi dati della scheda non si cambiano dall''app'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER "users_gruppo_immutabile" ON "public"."users";
CREATE TRIGGER "users_gruppo_immutabile"
  BEFORE UPDATE OF "id", "group_id", "account_attivo" ON "public"."users"
  FOR EACH ROW EXECUTE FUNCTION "public"."blocca_cambio_gruppo"();
