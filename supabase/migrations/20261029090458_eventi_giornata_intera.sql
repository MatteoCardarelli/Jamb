-- Eventi di una o più giornate intere (es. uscite, campi), senza orario.
--
-- Richiesto nel collaudo con gli utenti. Per un evento di giornata intera
-- l'app salva data_inizio alle 00:00 del primo giorno e data_fine alle 23:59
-- dell'ultimo, così i filtri per data esistenti continuano a funzionare.
-- Gli eventi già presenti restano con orario (default false).

ALTER TABLE "public"."events"
  ADD COLUMN "tutto_il_giorno" boolean NOT NULL DEFAULT false;
