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

L'applicazione è stata sviluppata e collaudata su **Android**. Le altre
piattaforme sono presenti nel progetto ma non sono state verificate.

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
completo è descritto nella documentazione di progetto, nel capitolo dedicato
alla progettazione del database.

### 4. Creazione degli utenti

> **Gli utenti vanno creati esclusivamente tramite Supabase Auth**, dalla
> console (*Authentication → Users → Add user*) oppure via Admin API.

Inserirli con una `INSERT` diretta in `auth.users` produce record con i campi
dei token a `NULL`, e il login fallisce con un errore 500
(`Database error querying schema`). È un problema già incontrato durante lo
sviluppo e documentato nelle decisioni di progetto.

Alla creazione, il trigger `handle_new_user` popola automaticamente la tabella
`users` leggendo `group_id`, `nome` e `cognome` dai metadati dell'utente.
Vanno quindi passati al momento della creazione, in *User Metadata*:

```json
{
  "group_id": "<uuid-del-gruppo>",
  "nome": "Mario",
  "cognome": "Rossi"
}
```

Perché l'utente veda qualcosa serve infine una riga in `memberships` che lo
colleghi a un'unità con un ruolo. Senza membership attiva le policy RLS non
restituiscono alcun dato e l'applicazione mostra la schermata "nessun ruolo".

## Avvio

```bash
flutter run
```

## Test

```bash
flutter test
```

La suite copre le entità di dominio, le funzioni di utilità e i ViewModel,
usando repository finti in memoria: non serve né connessione né database.

## Build di un APK

```bash
flutter build apk --release
```

L'archivio viene prodotto in `build/app/outputs/flutter-apk/`.

## Struttura del progetto

```
lib/
  config/        credenziali Supabase (non versionato)
  core/          client Supabase, sessione, utilità condivise
  domain/
    entities/    modelli di dominio (Scout, Evento, Transazione, ...)
    repositories/ interfacce dei repository
  data/
    repositories/ implementazioni Supabase e JSON
  ui/            una cartella per sezione, ciascuna con widget e view model
  app.dart       albero dei provider e gate di autenticazione
  main.dart      inizializzazione di Supabase e localizzazione
test/            test automatici, rispecchia la struttura di lib/
testing/         repository finti e costruttori di dati di prova
```

La scelta dell'implementazione dei repository avviene in `app.dart`: per
cambiare sorgente dati basta sostituire la classe registrata nel provider,
senza toccare interfaccia e view model.

## Limitazioni note

- Serve una connessione attiva. Il funzionamento offline è progettato ma non
  ancora implementato.
- Nella sezione Documenti si naviga soltanto: caricamento file e creazione
  cartelle non sono disponibili.
- La foto della ricevuta di una transazione viene selezionata ma non caricata.
- I pulsanti delle azioni rapide nella schermata principale non sono collegati.
- Gli errori dei repository non vengono mostrati a schermo: se un'operazione
  fallisce, l'interfaccia resta silenziosa.
- L'area dedicata ai ragazzi non esiste: l'applicazione è oggi rivolta ai soli
  capi.
