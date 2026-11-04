# Jamb

**App mobile per la gestione di un gruppo scout AGESCI**, pensata per i capi: anagrafica e progressione dei ragazzi, documenti amministrativi, contabilità di branca, calendario condiviso, obiettivi del Programma d'Unità e archivio documentale.

Progetto per l'esame di *Applicazioni per dispositivi mobili* — Università degli Studi dell'Aquila.

<p align="center">
  <img src="documentazione/images/iPhone%2017%20-%20Home%20(1).png" width="230" alt="Home">
  <img src="documentazione/images/iPhone%2017%20-%20Ragazzi.png" width="230" alt="Elenco ragazzi">
  <img src="documentazione/images/iPhone%2017%20-%20Sezione%20contabile.png" width="230" alt="Sezione contabile">
</p>
<p align="center"><sub>Mockup dell'interfaccia (dati di esempio)</sub></p>

## In breve

- **Flutter / Dart**, sviluppata e collaudata su Android
- **Supabase** (PostgreSQL + Auth) come backend, con **Row Level Security** su tutte le tabelle: ogni capo vede solo i dati della propria unità, in base al ruolo
- **Architettura MVVM**: i ViewModel dipendono dalle interfacce dei repository, mai dalle implementazioni; la sorgente dati si cambia in un solo punto
- **Schema versionato** con migrazioni Supabase CLI (15 tabelle, tipi enumerati, funzioni e policy)
- **Test automatici** su entità, permessi, gestione errori, ViewModel e widget, con repository finti in memoria
- **CI con GitHub Actions**: `flutter analyze` senza segnalazioni e `flutter test` a ogni push

## Struttura del repository

| Cartella | Contenuto |
|---|---|
| [`jamb/`](jamb/) | L'applicazione Flutter — **istruzioni di configurazione, avvio e test nel [README dell'app](jamb/README.md)** |
| [`supabase/`](supabase/) | Configurazione e migrazioni dello schema del database |
| [`documentazione/`](documentazione/) | Relazione di progetto (LaTeX), casi d'uso e mockup |

## Avvio rapido

```bash
cd jamb
flutter pub get
# crea lib/config/supabase_config.dart con URL e chiave anon del tuo progetto Supabase
flutter run
```

I dettagli (schema del database, creazione degli utenti, build dell'APK) sono nel [README dell'app](jamb/README.md).

## Autore

Matteo Cardarelli — [@MatteoCardarelli](https://github.com/MatteoCardarelli)
