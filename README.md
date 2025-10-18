# Tischtennis Trainingsplaner

Eine moderne Webanwendung zur Verwaltung von Tischtennistrainings, gebaut mit Astro, Supabase und TailwindCSS.

## Features

- **Benutzerrollen**: Trainer und Spieler mit unterschiedlichen Berechtigungen
- **Trainer-Dashboard**: Trainings erstellen, verwalten und Teilnehmerlisten einsehen
- **Spieler-Anmeldung**: Einfache Anmeldung zu Trainings mit Kapazitätskontrolle
- **Responsive Design**: Optimiert für Desktop und Mobile
- **Persistente Datenbank**: Supabase PostgreSQL
- **Einfaches Deployment**: Bereit für IONOS Deploy Now

## Technologie-Stack

- **Framework**: Astro 4 (SSR)
- **Datenbank**: Supabase (PostgreSQL)
- **Styling**: TailwindCSS 3
- **Authentifizierung**: Session-basiert mit bcryptjs
- **Deployment**: IONOS Deploy Now
- **Sprache**: TypeScript

---

## Einrichtung - Schritt für Schritt

### 1. Repository klonen

```bash
git clone <dein-repository-url>
cd table_tennis_planner
```

### 2. Dependencies installieren

```bash
npm install
```

### 3. Supabase einrichten

#### 3.1 Supabase-Projekt erstellen

1. Gehe zu [supabase.com](https://supabase.com)
2. Registriere dich oder melde dich an
3. Klicke auf "New Project"
4. Fülle die folgenden Felder aus:
   - **Name**: table-tennis-planner (oder ein anderer Name)
   - **Database Password**: Wähle ein sicheres Passwort (speichere es gut!)
   - **Region**: Wähle eine Region in deiner Nähe (z.B. Frankfurt)
5. Klicke auf "Create new project"
6. Warte, bis das Projekt erstellt wurde (ca. 2 Minuten)

#### 3.2 Datenbank-Schema erstellen

1. In deinem Supabase-Projekt, klicke links auf **"SQL Editor"**
2. Klicke auf **"New query"**
3. Öffne die Datei `supabase-schema.sql` in deinem Projekt
4. Kopiere den gesamten Inhalt
5. Füge den Code in den SQL-Editor ein
6. Klicke auf **"Run"** (oder drücke Strg+Enter)
7. Du solltest die Meldung "Success. No rows returned" sehen

#### 3.3 Supabase-Zugangsdaten kopieren

1. Klicke links auf **"Project Settings"** (Zahnrad-Icon)
2. Klicke auf **"API"**
3. Kopiere folgende Werte:
   - **Project URL** (steht unter "Project URL")
   - **anon/public Key** (steht unter "Project API keys" → "anon public")

#### 3.4 Umgebungsvariablen einrichten

1. Erstelle eine `.env` Datei im Projekt-Root:

```bash
cp .env.example .env
```

2. Öffne die `.env` Datei und füge deine Werte ein:

```env
PUBLIC_SUPABASE_URL=https://deinprojekt.supabase.co
PUBLIC_SUPABASE_ANON_KEY=dein-anon-key-hier
```

### 4. Lokaler Development Server

Starte den Development-Server:

```bash
npm run dev
```

Die Anwendung läuft jetzt auf `http://localhost:4321`

**Teste die Anwendung:**

1. Öffne `http://localhost:4321`
2. Klicke auf "Jetzt registrieren"
3. Erstelle einen Account als **Trainer**
4. Teste das Erstellen von Trainings
5. Öffne einen zweiten Browser (oder Inkognito-Modus)
6. Erstelle einen zweiten Account als **Spieler**
7. Melde dich für ein Training an

### 5. Deployment auf IONOS Deploy Now

#### 5.1 Git-Repository erstellen (falls noch nicht geschehen)

```bash
git init
git add .
git commit -m "Initial commit: Tischtennis Trainingsplaner mit Astro und Supabase"
```

#### 5.2 Zu GitHub pushen

1. Gehe zu [github.com](https://github.com)
2. Erstelle ein neues Repository (z.B. "table-tennis-planner")
3. Folge den Anweisungen, um dein lokales Repository zu pushen:

```bash
git remote add origin https://github.com/dein-username/table-tennis-planner.git
git branch -M main
git push -u origin main
```

#### 5.3 IONOS Deploy Now einrichten

1. Gehe zu [ionos.de/hosting/deploy-now](https://www.ionos.de/hosting/deploy-now)
2. Melde dich an oder registriere dich
3. Klicke auf **"Neues Projekt"**
4. Wähle **"Von GitHub importieren"**
5. Autorisiere IONOS für Zugriff auf dein GitHub-Repository
6. Wähle dein Repository aus: `table-tennis-planner`
7. IONOS erkennt automatisch, dass es ein Node.js-Projekt ist

#### 5.4 Build-Einstellungen konfigurieren

IONOS sollte automatisch folgende Einstellungen erkennen:

- **Framework**: Astro
- **Build Command**: `npm run build`
- **Output Directory**: `dist`
- **Install Command**: `npm ci`

Falls nicht, trage sie manuell ein.

#### 5.5 Umgebungsvariablen in IONOS setzen

1. In deinem IONOS-Projekt, gehe zu **"Einstellungen"** → **"Umgebungsvariablen"**
2. Füge folgende Variablen hinzu:

```
PUBLIC_SUPABASE_URL = https://deinprojekt.supabase.co
PUBLIC_SUPABASE_ANON_KEY = dein-anon-key-hier
```

3. Speichere die Einstellungen

#### 5.6 Deployment starten

1. Klicke auf **"Deploy"** oder pushe eine Änderung zu GitHub
2. IONOS startet automatisch den Build-Prozess
3. Nach ca. 2-3 Minuten ist deine Anwendung live!
4. Du erhältst eine URL wie: `https://deinprojekt.ionos.space`

---

## Projektstruktur

```
table_tennis_planner/
├── src/
│   ├── layouts/
│   │   └── Layout.astro          # Haupt-Layout mit Navigation
│   ├── lib/
│   │   ├── db.ts                 # Datenbank-Funktionen (Supabase)
│   │   ├── supabase.ts           # Supabase Client
│   │   └── types.ts              # TypeScript Typen
│   ├── pages/
│   │   ├── index.astro           # Startseite
│   │   ├── login.astro           # Login-Seite
│   │   ├── register.astro        # Registrierungs-Seite
│   │   ├── trainings.astro       # Spieler-Trainingsübersicht
│   │   ├── trainer/
│   │   │   └── dashboard.astro   # Trainer-Dashboard
│   │   └── api/
│   │       └── logout.ts         # Logout API-Endpunkt
│   └── styles/
│       └── global.css            # Globale Styles mit Tailwind
├── astro.config.mjs              # Astro-Konfiguration
├── tailwind.config.js            # TailwindCSS-Konfiguration
├── supabase-schema.sql           # Datenbank-Schema für Supabase
├── .env.example                  # Beispiel für Umgebungsvariablen
└── .deploy-now.yaml              # IONOS Deploy Now Konfiguration
```

---

## Verwendung

### Als Trainer

1. Registrieren mit Rolle "Trainer"
2. Im Dashboard auf "+ Neues Training erstellen" klicken
3. Datum, Uhrzeit und maximale Teilnehmerzahl eingeben
4. Training wird automatisch erstellt und angezeigt
5. Angemeldete Spieler werden in Echtzeit angezeigt
6. Trainings können jederzeit gelöscht werden

### Als Spieler

1. Registrieren mit Rolle "Spieler"
2. Verfügbare Trainings in der Übersicht ansehen
3. Auf "Anmelden" klicken, um sich für ein Training anzumelden
4. Auf "Abmelden" klicken, um eine Anmeldung zu stornieren
5. Eigene Anmeldungen werden unten aufgelistet

---

## Häufige Probleme und Lösungen

### Problem: "Supabase URL und Anon Key müssen in .env gesetzt sein"

**Lösung**:
- Überprüfe, dass die `.env` Datei existiert
- Stelle sicher, dass die Variablen `PUBLIC_SUPABASE_URL` und `PUBLIC_SUPABASE_ANON_KEY` korrekt gesetzt sind
- Starte den Dev-Server neu: `npm run dev`

### Problem: Build-Fehler bei IONOS Deploy Now

**Lösung**:
- Überprüfe, dass alle Umgebungsvariablen in IONOS gesetzt sind
- Stelle sicher, dass der Build-Command `npm run build` ist
- Prüfe die Build-Logs in IONOS für detaillierte Fehlermeldungen

### Problem: "Error: relation 'users' does not exist"

**Lösung**:
- Das Datenbank-Schema wurde nicht korrekt ausgeführt
- Gehe zurück zu Schritt 3.2 und führe das SQL-Script erneut aus

### Problem: Session funktioniert nicht / User wird nicht eingeloggt

**Lösung**:
- Lösche Browser-Cookies
- Überprüfe, dass die Supabase-Verbindung funktioniert
- Prüfe in Supabase unter "Authentication" → "Users", ob User erstellt werden

---

## Verbesserungen durch Claude Code

### Behobene Probleme:

1. **Datenbank-Mapping korrigiert** (src/lib/db.ts)
   - Problem: Supabase gibt Daten in snake_case zurück, TypeScript erwartet camelCase
   - Lösung: Konvertierung zwischen Datenbank-Schema (snake_case) und TypeScript-Typen (camelCase) in allen CRUD-Operationen
   - Betroffene Funktionen: `users.getAll()`, `users.getById()`, `users.getByEmail()`, `users.create()`, sowie alle Training- und Attendance-Funktionen

2. **Import-Fehler behoben** (src/pages/login.astro:13)
   - Problem: Falscher bcrypt-Import führte zu Runtime-Fehlern
   - Lösung: Korrekter Default-Import: `(await import('bcryptjs')).default`

3. **Typ-Sicherheit verbessert**
   - Alle Datenbank-Operationen haben nun korrekte TypeScript-Typen
   - Null-Checks vor der Datenverarbeitung hinzugefügt
   - Konsistente Datenstrukturen im gesamten Projekt

4. **.env.example erstellt**
   - Template für Umgebungsvariablen hinzugefügt
   - Bessere Dokumentation für neue Entwickler

### Best Practices implementiert:

- Konsistente Fehlerbehandlung in allen API-Endpunkten
- Kommentare für bessere Code-Lesbarkeit
- Separation of Concerns: Datenbank-Logik getrennt von UI-Komponenten
- Server-Side Rendering für bessere Performance und SEO

---

## Weiterentwicklungsmöglichkeiten

- **E-Mail-Benachrichtigungen**: Automatische Benachrichtigungen bei neuen Trainings
- **Kalender-Integration**: Export in Google Calendar / Outlook
- **Warteliste**: Automatische Nachrücken bei Absagen
- **Kommentare**: Trainer können Notizen zu Trainings hinzufügen
- **Statistiken**: Teilnahme-Statistiken für Spieler
- **Multi-Tenant**: Mehrere Vereine auf einer Plattform
- **PDF-Export**: Teilnehmerlisten als PDF herunterladen

---

## Sicherheitshinweise

- Die Passwörter werden mit bcryptjs gehasht (nicht im Klartext gespeichert)
- Supabase Row Level Security (RLS) ist aktiviert
- Sessions sind httpOnly und secure (in Produktion)
- API-Keys sollten niemals im Git-Repository committet werden

---

## Support und Hilfe

Bei Fragen oder Problemen:

1. Prüfe die [Astro-Dokumentation](https://docs.astro.build)
2. Prüfe die [Supabase-Dokumentation](https://supabase.com/docs)
3. Erstelle ein Issue im GitHub-Repository

---

## Lizenz

MIT

---

## Checkliste für Deployment

- [ ] Supabase-Projekt erstellt
- [ ] Datenbank-Schema ausgeführt (supabase-schema.sql)
- [ ] Lokale .env Datei erstellt mit Supabase-Credentials
- [ ] Lokal getestet (npm run dev)
- [ ] Git-Repository erstellt und zu GitHub gepusht
- [ ] IONOS Deploy Now Projekt erstellt
- [ ] Umgebungsvariablen in IONOS gesetzt
- [ ] Deployment erfolgreich
- [ ] Live-Test: Registrierung, Login, Training erstellen, Anmeldung

---

**Viel Erfolg mit deinem Tischtennis Trainingsplaner!** 🏓
