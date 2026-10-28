-- Rimuove le funzioni di supporto residue di una prima versione delle policy.
-- Nessuna policy, funzione o parte dell'app le usa: le policy attuali si
-- appoggiano solo a ruolo_in_unita, is_capo_gruppo, mio_group_id e mia_unit_id.
-- ruolo_in_uscita era un duplicato (refuso) di ruolo_in_unita.
--
-- Senza CASCADE: se qualcosa dipendesse ancora da una di queste funzioni,
-- la migrazione fallisce invece di eliminare oggetti in silenzio.

DROP FUNCTION IF EXISTS "public"."ruolo_in_uscita"("uuid");
DROP FUNCTION IF EXISTS "public"."get_my_group_id"();
DROP FUNCTION IF EXISTS "public"."get_my_unit_ids"();
DROP FUNCTION IF EXISTS "public"."get_my_squad_ids"();
DROP FUNCTION IF EXISTS "public"."is_at_least_capo_sq"();
DROP FUNCTION IF EXISTS "public"."is_at_least_aiuto_capo"();
DROP FUNCTION IF EXISTS "public"."is_at_least_capo_unita"();
DROP FUNCTION IF EXISTS "public"."is_capo_della_stessa_unita"("uuid");
