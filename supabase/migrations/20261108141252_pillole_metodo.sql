-- Pillole del metodo (US8).
--
-- Una tabella sola per metodo e, in futuro, spiritualità (US33). `group_id` nullo
-- indica una pillola comune a tutti i gruppi: si legge ma non si modifica dall'app.
-- Le pillole del gruppo le scrivono Capo Unità e Capo Gruppo (decisione
-- dell'utente del 2026-11-08), la stessa soglia delle librerie di gruppo.

CREATE TABLE "public"."pillole" (
  "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  "group_id" uuid REFERENCES "public"."groups"("id") ON DELETE CASCADE,
  "tipo" text NOT NULL DEFAULT 'metodo' CHECK ("tipo" IN ('metodo', 'spiritualita')),
  "branca" "public"."tipo_branca_enum" NOT NULL,
  "testo" text NOT NULL CHECK (btrim("testo") <> '' AND char_length("testo") <= 500),
  "autore_id" uuid DEFAULT auth.uid() REFERENCES "public"."users"("id") ON DELETE SET NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

CREATE INDEX "idx_pillole_branca" ON "public"."pillole" ("branca", "tipo");
CREATE INDEX "idx_pillole_group" ON "public"."pillole" ("group_id");

ALTER TABLE "public"."pillole" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "pillole_select" ON "public"."pillole" FOR SELECT TO "authenticated"
  USING (
    ("group_id" IS NULL AND "public"."sono_capo"())
    OR "public"."posso_leggere_libreria"("group_id")
  );

CREATE POLICY "pillole_insert" ON "public"."pillole" FOR INSERT TO "authenticated"
  WITH CHECK ("group_id" IS NOT NULL AND "public"."posso_scrivere_libreria"("group_id"));

CREATE POLICY "pillole_update" ON "public"."pillole" FOR UPDATE TO "authenticated"
  USING ("group_id" IS NOT NULL AND "public"."posso_scrivere_libreria"("group_id"))
  WITH CHECK ("group_id" IS NOT NULL AND "public"."posso_scrivere_libreria"("group_id"));

CREATE POLICY "pillole_delete" ON "public"."pillole" FOR DELETE TO "authenticated"
  USING ("group_id" IS NOT NULL AND "public"."posso_scrivere_libreria"("group_id"));

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "public"."pillole" TO "authenticated";

-- Primi testi, comuni a tutti i gruppi (da far rileggere all'utente).

INSERT INTO "public"."pillole" ("group_id", "branca", "testo", "autore_id") VALUES
  (NULL, 'LC', 'Il Branco vive dentro un ambiente fantastico: la Giungla non è un travestimento, ma il linguaggio con cui i bambini capiscono la Legge.', NULL),
  (NULL, 'LC', 'Il gioco è lo strumento principale del Branco: un bambino che gioca sta già imparando a stare con gli altri.', NULL),
  (NULL, 'LC', 'A ogni lupetto e coccinella si chiede di fare del proprio meglio, non di essere il migliore.', NULL),
  (NULL, 'LC', 'La Sestiglia dà a ogni bambino un piccolo gruppo in cui sentirsi riconosciuto, e al capo sestiglia le prime responsabilità.', NULL),
  (NULL, 'LC', 'Al Consiglio della Rupe il Branco si riunisce per scegliere e verificare: la parola di ogni lupetto conta.', NULL),
  (NULL, 'LC', 'I Vecchi Lupi raccontano più di quanto spieghino: nei personaggi delle storie i bambini riconoscono i propri comportamenti.', NULL),
  (NULL, 'EG', 'Il Consiglio della Legge non è un tribunale: è il momento in cui il Reparto si ferma a verificare se la Legge è vissuta davvero.', NULL),
  (NULL, 'EG', 'La Squadriglia è il luogo dell''autonomia: i capi accompagnano, ma sono i ragazzi a decidere, fare e verificare.', NULL),
  (NULL, 'EG', 'Un''impresa nasce da un''idea dei ragazzi e arriva fino alla verifica: saltarla significa perdere metà del valore educativo.', NULL),
  (NULL, 'EG', 'Il Sentiero è personale: ognuno cammina al proprio passo, con impegni scelti e verificati insieme.', NULL),
  (NULL, 'EG', 'Le specialità nascono dal saper fare: servono a scoprire un talento e a metterlo a servizio della Squadriglia.', NULL),
  (NULL, 'EG', 'Il Consiglio Capi è dove i capi Squadriglia imparano a rappresentare gli altri: date loro responsabilità vere, non solo incarichi.', NULL),
  (NULL, 'RS', 'La Strada è maestra: camminare insieme, con fatica ed essenzialità, insegna più di molti discorsi.', NULL),
  (NULL, 'RS', 'La Carta di Clan è il patto che rover e scolte scrivono e verificano insieme: è lì che la Comunità si riconosce.', NULL),
  (NULL, 'RS', 'Il Capitolo è il modo in cui il Clan approfondisce un tema, si fa un''opinione e sceglie come agire.', NULL),
  (NULL, 'RS', 'Il servizio non è un''attività tra le altre: è il modo in cui rover e scolte imparano a spendersi per gli altri.', NULL),
  (NULL, 'RS', 'Il Punto della Strada aiuta ciascuno a fermarsi, guardare il cammino fatto e scegliere i passi successivi.', NULL),
  (NULL, 'RS', 'La Partenza è il punto d''arrivo del cammino: la scelta libera di vivere da adulti i valori della Promessa.', NULL);
