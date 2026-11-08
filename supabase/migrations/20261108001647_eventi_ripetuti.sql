-- Eventi che si ripetono (segnalazione dell'utente del 2026-11-08).
--
-- Ogni data della ripetizione è una riga di `events`, con il suo appello;
-- le righe della stessa ripetizione condividono `serie_id`. Decisioni
-- dell'utente: la ripetizione arriva fino a una data scelta; modificando o
-- eliminando un evento della serie si sceglie «solo questo» o «questo e i
-- successivi». Le policy esistenti valgono riga per riga, senza modifiche.

ALTER TABLE "public"."events"
  ADD COLUMN "serie_id" uuid,
  ADD COLUMN "ripetizione" text,
  ADD CONSTRAINT "events_ripetizione_check"
    CHECK ("ripetizione" IN ('giornaliera', 'settimanale', 'mensile', 'annuale')),
  -- Una serie ha sempre un tipo di ripetizione, un evento singolo nessuno.
  ADD CONSTRAINT "events_serie_check"
    CHECK (("serie_id" IS NULL) = ("ripetizione" IS NULL));

-- Per trovare gli eventi successivi della stessa serie.
CREATE INDEX "idx_events_serie" ON "public"."events" ("serie_id", "data_inizio")
  WHERE "serie_id" IS NOT NULL;
