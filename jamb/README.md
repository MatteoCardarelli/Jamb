# Jamb

Applicazione Flutter per la gestione di un gruppo scout AGESCI: anagrafica e
progressione dei ragazzi, stato dei documenti amministrativi, contabilità di
branca, calendario condiviso, obiettivi del Programma d'Unità e archivio
documentale.

Progetto realizzato per l'esame di *Applicazioni per dispositivi mobili*,
Università degli Studi dell'Aquila.

Il backend è [Supabase](https://supabase.com) (PostgreSQL + Auth), con Row
Level Security attiva su tutte le tabelle. L'architettura segue il pattern
MVVM: i ViewModel dipendono dalle interfacce dei repository, mai dalle loro
implementazioni.

## Prerequisiti

- Flutter SDK `>= 3.11.0` (`flutter --version`)
- Android SDK con un emulatore configurato, oppure un dispositivo fisico con
  il debug USB attivo
- Un progetto Supabase, anche sul piano gratuito

L'applicazione è stata sviluppata e collaudata su **Android**. La versione
**web** si compila e si apre (vedi «Versione web»); le altre piattaforme sono
presenti nel progetto ma non sono state verificate.

## Configurazione

### 1. Dipendenze

```bash
cd jamb
flutter pub get
```

### 2. Credenziali Supabase

Il file con le credenziali **non è versionato** (è in `.gitignore`), quindi
dopo il clone va creato a mano. Crea `lib/config/supabase_config.dart` con
questo contenuto:

```dart
const supabaseUrl = 'https://<id-progetto>.supabase.co';
const supabaseAnonKey = '<chiave-anon>';
```

Entrambi i valori si trovano nella console Supabase, in
*Project Settings → API*. La chiave `anon` è pubblica per definizione: la
protezione dei dati non dipende da lei ma dalle policy RLS.

Senza questo file il progetto non compila.

### 3. Base di dati

Il progetto Supabase deve contenere lo schema dell'applicazione: le quindici
tabelle, i tipi enumerati, le funzioni di supporto e le policy RLS. Lo schema
è versionato nella cartella `supabase/migrations/` della root del repository
e si applica a un nuovo progetto con la Supabase CLI (serve Node.js):

```bash
npx supabase login
npx supabase link --project-ref <id-progetto>
npx supabase db push
```

Ogni modifica successiva allo schema va fatta con una nuova migrazione
(`npx supabase migration new <nome>`), mai a mano dalla console.

### 4. Persone e account

Ogni persona, capo o ragazzo, è prima di tutto una **scheda** nella tabella
`users`; l'account per accedere è facoltativo e si aggancia alla scheda con
lo **stesso id**. Un account senza scheda viene rifiutato dal trigger
`handle_new_user`, così la registrazione libera non crea profili.

Per creare una persona con un account (lo fanno gli script del punto 5, con
`tool/supabase_admin.dart`):

1. inserire la scheda in `users` (gruppo, nome, cognome);
2. creare l'account con l'Admin API di Supabase Auth, passando l'`id` della
   scheda (`POST /auth/v1/admin/users` con `id`, email e password).

> **Mai una `INSERT` diretta in `auth.users`**: lascia i campi dei token a
> `NULL` e il login fallisce con un errore 500 (`Database error querying
> schema`). Dalla console (*Add user*) non si può scegliere l'id, quindi
> l'account verrebbe rifiutato.

Perché la persona veda qualcosa serve infine una riga in `memberships` che la
colleghi a un'unità con un ruolo. Senza membership attiva le policy RLS non
restituiscono alcun dato e l'applicazione mostra la schermata "nessun ruolo".
I ragazzi si aggiungono anche dall'app (Capo Unità o Capo Gruppo), senza account.

### 5. Dati di prova (facoltativo)

`tool/crea_dati_prova.dart` crea via Admin API un gruppo di prova con le quattro
unità, due squadriglie e otto utenti `prova.*@test.it`. Si può rilanciare: ciò che
esiste già viene riusato. La chiave `service_role` scavalca le RLS, quindi va
passata solo nell'ambiente, e `JAMB_CONFERMA_PROGETTO` deve ripetere il
riferimento del progetto:

```bash
SUPABASE_URL=https://<ref>.supabase.co SUPABASE_SERVICE_ROLE_KEY=<chiave> JAMB_PASSWORD_PROVA=<password> JAMB_CONFERMA_PROGETTO=<ref> dart run tool/crea_dati_prova.dart
```

### 6. Gruppo dimostrativo (facoltativo)

`tool/crea_gruppo_dimostrativo.dart` crea «Valle Serena 1», un gruppo inventato
da mostrare a chi prova l'app: Branco, Reparto e Clan con 29 ragazzi, cinque capi
e l'Assistente Ecclesiastico, riunioni passate e future con l'appello fatto,
cassa, avvisi, Programma d'Unità collegato al PEG, un campo invernale e l'iter
formativo dei capi. Nomi e telefoni sono finti e le date partono dal giorno in
cui si lancia. Si può rilanciare: i contenuti si creano solo la prima volta.

```bash
SUPABASE_URL=https://<ref>.supabase.co SUPABASE_SERVICE_ROLE_KEY=<chiave> JAMB_PASSWORD_DEMO=<password> JAMB_CONFERMA_PROGETTO=<ref> dart run tool/crea_gruppo_dimostrativo.dart
```

Alla fine stampa gli account; per vedere tutto si entra come Capo Gruppo.

## Avvio

```bash
flutter run
```

## Versione web

Lo stesso codice si compila anche per il browser: si apre da un collegamento
(anche su iPhone e computer) e si può installare sulla schermata Home.

```bash
flutter build web --release
```

Il risultato in `build/web/` è un sito statico, da pubblicare su un qualunque
hosting di file statici.

La CI lo fa da sola su Netlify: a ogni push su `main` con analisi e test verdi
compila la versione web e la pubblica. Servono quattro segreti del repository
(*Settings → Secrets and variables → Actions*): `NETLIFY_AUTH_TOKEN`,
`NETLIFY_SITE_ID`, `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY`. Finché mancano,
la pubblicazione viene saltata con un avviso. Sul computer l'app resta larga come un telefono, al
centro dello schermo.

## Test

```bash
flutter test
```

La suite copre le entità di dominio, i permessi, la traduzione degli errori, i
ViewModel e alcuni widget, usando repository finti in memoria: non serve né
connessione né database. Alcuni test leggono le migrazioni in
`../supabase/migrations/` per verificare il contratto con lo schema.

A ogni push la CI di GitHub Actions (`.github/workflows/flutter.yml`) esegue
`flutter analyze`, che deve restare senza segnalazioni, e `flutter test`.

## Build di un APK

```bash
flutter build apk --release
```

L'archivio viene prodotto in `build/app/outputs/flutter-apk/`.

## Struttura del progetto

```
lib/
  config/        credenziali Supabase (non versionato)
  core/          client Supabase, sessione, permessi, utilità condivise
  domain/
    entities/    modelli di dominio (Scout, Evento, Transazione, ...)
    errori/      eccezione di dominio JambException
    repositories/ interfacce dei repository
  data/
    repositories/ implementazioni Supabase
    errori_supabase.dart traduzione degli errori di Supabase e della rete
  ui/            una cartella per sezione, ciascuna con widget e view model;
                 ui/core/ contiene i widget condivisi
  app.dart       albero dei provider e gate di autenticazione
  main.dart      inizializzazione di Supabase e localizzazione
test/            test automatici, rispecchia la struttura di lib/
testing/         repository finti e costruttori di dati di prova
```

La scelta dell'implementazione dei repository avviene in `app.dart`: per
cambiare sorgente dati basta sostituire la classe registrata nel provider,
senza toccare interfaccia e view model. Repository e view model vengono
ricreati a ogni cambio di utente, così non restano in memoria i dati di chi
è uscito.

## Limitazioni note

- Serve una connessione attiva. Il funzionamento offline è progettato ma non
  ancora implementato.
- I file del Drive e le ricevute si aprono con le app del telefono (lettore PDF,
  galleria): l'applicazione non ha un visualizzatore interno.
- Gli avvisi di un altro capo arrivano in tempo reale; un avviso eliminato
  sparisce alla prossima apertura della bacheca.
- Chi opera in più unità le sceglie dal menu del profilo; cambiando unità
  l'applicazione torna alla schermata principale.
- L'area dedicata ai ragazzi non esiste: l'applicazione è oggi rivolta ai soli
  capi, e un ragazzo che accede vede solo un avviso.
