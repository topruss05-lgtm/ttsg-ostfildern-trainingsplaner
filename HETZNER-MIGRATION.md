# Migration zu Hetzner + PocketBase

Komplette Anleitung für den Umzug von Supabase + Deploy Now zu Hetzner Cloud + PocketBase

---

## Warum dieser Umzug?

✅ **Volle Kontrolle** - Du besitzt die Daten
✅ **Einfacher** - Kein komplexes Supabase-Setup
✅ **Günstiger** - 5-15€/Monat für alles
✅ **DSGVO** - 100% in Deutschland gehostet
✅ **Lernen** - Verstehe, wie deine Infrastruktur funktioniert

---

## Voraussetzungen

- [ ] Hetzner-Account (https://hetzner.com)
- [ ] Domain (z.B. bei IONOS, Namecheap, etc.)
- [ ] SSH-Kenntnisse (Grundlagen reichen)
- [ ] 30-60 Minuten Zeit

---

## Phase 1: Hetzner Server erstellen (5 Minuten)

### Schritt 1.1: Bei Hetzner anmelden

1. Gehe zu https://console.hetzner.cloud
2. Registriere dich oder logge dich ein
3. Erstelle ein neues Projekt: "trainingsplaner"

### Schritt 1.2: Server erstellen

1. Klicke auf **"Server hinzufügen"**
2. Wähle folgende Optionen:

| Option | Auswahl |
|--------|---------|
| **Standort** | Falkenstein (Deutschland) |
| **Image** | Ubuntu 24.04 |
| **Typ** | **CPX21** (3 vCPU, 4 GB RAM, 80 GB SSD) - 15€/Mo |
| **Networking** | IPv4 + IPv6 |
| **SSH-Key** | Erstelle einen neuen SSH-Key (siehe unten) |
| **Name** | trainingsplaner-prod |

### Schritt 1.3: SSH-Key erstellen (falls noch nicht vorhanden)

**Auf deinem Computer:**

```bash
# SSH-Key generieren
ssh-keygen -t ed25519 -C "deine@email.de"

# Public Key anzeigen
cat ~/.ssh/id_ed25519.pub

# Kopiere den Output und füge ihn in Hetzner ein
```

### Schritt 1.4: Server starten

- Klicke auf **"Erstellen und starten"**
- Warte ~30 Sekunden
- **Notiere die IP-Adresse** (z.B. 135.181.10.20)

---

## Phase 2: DNS konfigurieren (10 Minuten)

### Schritt 2.1: Domain vorbereiten

Angenommen deine Domain ist: **ttsg-ostfildern.de**

Gehe zu deinem Domain-Provider (IONOS, Namecheap, etc.) und erstelle folgende DNS-Records:

| Typ | Name | Wert | TTL |
|-----|------|------|-----|
| A | trainingsplaner | `<DEINE-SERVER-IP>` | 300 |
| A | admin.trainingsplaner | `<DEINE-SERVER-IP>` | 300 |

**Beispiel:**
- `trainingsplaner.ttsg-ostfildern.de` → `135.181.10.20`
- `admin.trainingsplaner.ttsg-ostfildern.de` → `135.181.10.20`

**Warte 5-10 Minuten** bis DNS propagiert ist.

**Test:**
```bash
ping trainingsplaner.ttsg-ostfildern.de
# Sollte deine Server-IP zeigen
```

---

## Phase 3: Server einrichten (15 Minuten)

### Schritt 3.1: Auf Server verbinden

```bash
# Ersetze IP mit deiner Server-IP
ssh root@135.181.10.20
```

Bei erster Verbindung: Tippe `yes` + Enter

### Schritt 3.2: Setup-Script hochladen und ausführen

**Auf deinem Computer:**

```bash
# Navigiere zu deinem Projekt
cd ~/path/to/ttsg-ostfildern-trainingsplaner

# Script auf Server kopieren
scp hetzner-setup.sh root@135.181.10.20:/root/

# Auf Server verbinden
ssh root@135.181.10.20

# Script ausführen
cd /root
chmod +x hetzner-setup.sh
./hetzner-setup.sh
```

**Das Script fragt dich nach deiner Domain!**

Gib ein: `trainingsplaner.ttsg-ostfildern.de`

**Warte ~2-3 Minuten** bis das Script fertig ist.

### Schritt 3.3: SSL-Zertifikat prüfen

```bash
# Caddy Status checken
systemctl status caddy

# Logs ansehen
journalctl -u caddy -f
```

**Wenn alles klappt, siehst du:**
```
✅ Serving HTTPS on trainingsplaner.ttsg-ostfildern.de
✅ Serving HTTPS on admin.trainingsplaner.ttsg-ostfildern.de
```

---

## Phase 4: PocketBase konfigurieren (10 Minuten)

### Schritt 4.1: Admin-Account erstellen

1. Öffne **https://admin.trainingsplaner.ttsg-ostfildern.de/_/**
2. Du siehst den PocketBase-Setup-Screen
3. Erstelle deinen Admin-Account:
   - Email: `deine@email.de`
   - Password: `<sicheres-passwort>`

### Schritt 4.2: Collections erstellen

**Option A: Über die Admin-UI (manuell)**

1. Klicke auf **"New collection"** → **"Auth collection"**
2. Name: `users`
3. Füge Felder hinzu:
   - `name` (Text, required)
   - `role` (Select, required, options: `player`, `trainer`)
4. **API Rules** setzen:
   - List: `@request.auth.id != ""`
   - View: `@request.auth.id != ""`
   - Create: `` (leer = öffentlich)
   - Update: `@request.auth.id = id`
   - Delete: `null`

Wiederhole für `trainings` und `attendances` (siehe pocketbase-collections.json)

**Option B: Collections importieren (schneller)**

```bash
# Auf deinem Server
cd /opt
systemctl stop pocketbase

# Collections-Datei von deinem Computer hochladen
# (auf deinem Computer ausführen)
scp pocketbase-collections.json root@<SERVER-IP>:/opt/pb_data/

# Collections importieren
# (auf dem Server)
./pocketbase collections import /opt/pb_data/pocketbase-collections.json

# PocketBase neu starten
systemctl start pocketbase
```

### Schritt 4.3: Test-User erstellen

In der Admin-UI:
1. Gehe zu **Collections** → **users**
2. Klicke **"New record"**
3. Erstelle einen Test-Trainer:
   - Email: `trainer@test.de`
   - Password: `testtest`
   - Name: `Test Trainer`
   - Role: `trainer`

---

## Phase 5: Code anpassen & deployen (20 Minuten)

### Schritt 5.1: Dependencies installieren

```bash
# Auf deinem Computer
cd ~/path/to/ttsg-ostfildern-trainingsplaner

# Alte Dependencies entfernen
npm uninstall @supabase/supabase-js

# Neue Dependencies installieren
npm install pocketbase@^0.21.0
```

### Schritt 5.2: Dateien umbenennen

```bash
# Login & Register auf neue Versionen umstellen
mv src/pages/login.astro src/pages/login-old.astro
mv src/pages/register.astro src/pages/register-old.astro
mv src/pages/login-new.astro src/pages/login.astro
mv src/pages/register-new.astro src/pages/register.astro
```

### Schritt 5.3: .env aktualisieren

```bash
# .env bearbeiten
nano .env
```

Ersetze mit:
```env
PUBLIC_POCKETBASE_URL=https://trainingsplaner.ttsg-ostfildern.de
```

### Schritt 5.4: Lokal testen

```bash
# Dev-Server starten
npm run dev
```

**Öffne:** http://localhost:4321

**WICHTIG:** Lokaler Dev nutzt PocketBase auf dem Server!
(Für lokales PocketBase siehe unten)

**Teste:**
1. Login mit `trainer@test.de` / `testtest`
2. Training erstellen
3. Logout / neuen Spieler registrieren
4. Für Training anmelden

Funktioniert alles? ✅ Weiter zu Schritt 5.5

### Schritt 5.5: GitHub Secrets konfigurieren

**Auf GitHub:**

1. Gehe zu deinem Repo: https://github.com/topruss05-lgtm/ttsg-ostfildern-trainingsplaner
2. **Settings** → **Secrets and variables** → **Actions**
3. Erstelle folgende Secrets:

| Name | Value |
|------|-------|
| `PUBLIC_POCKETBASE_URL` | `https://trainingsplaner.ttsg-ostfildern.de` |
| `HETZNER_HOST` | `<DEINE-SERVER-IP>` |
| `HETZNER_USER` | `root` |
| `HETZNER_SSH_KEY` | `<DEIN-PRIVATER-SSH-KEY>` |

**HETZNER_SSH_KEY bekommen:**
```bash
# Auf deinem Computer
cat ~/.ssh/id_ed25519
# Kopiere den GANZEN Output (inklusive BEGIN/END)
```

### Schritt 5.6: Deployen!

```bash
# Committe alle Änderungen
git add .
git commit -m "Migration zu Hetzner + PocketBase"
git push origin main
```

**GitHub Actions startet automatisch!**

Gehe zu: https://github.com/topruss05-lgtm/ttsg-ostfildern-trainingsplaner/actions

Nach ~2-3 Minuten solltest du sehen: ✅ **Deploy successful**

---

## Phase 6: Live-Test (5 Minuten)

### Öffne deine App

**https://trainingsplaner.ttsg-ostfildern.de**

**Teste:**
1. ✅ Registrierung funktioniert
2. ✅ Login funktioniert
3. ✅ Trainer kann Trainings erstellen
4. ✅ Spieler können sich anmelden

---

## Bonus: Lokales PocketBase für Entwicklung

**Warum?** Damit du offline entwickeln kannst ohne Server zu brauchen.

```bash
# PocketBase lokal herunterladen
cd ~/Downloads
wget https://github.com/pocketbase/pocketbase/releases/download/v0.22.0/pocketbase_0.22.0_darwin_amd64.zip  # Mac
# oder
wget https://github.com/pocketbase/pocketbase/releases/download/v0.22.0/pocketbase_0.22.0_linux_amd64.zip   # Linux

unzip pocketbase_*.zip
chmod +x pocketbase

# In Projekt-Verzeichnis verschieben
mv pocketbase ~/path/to/ttsg-ostfildern-trainingsplaner/

# Starten
./pocketbase serve
```

**Admin-UI:** http://127.0.0.1:8090/_/

Erstelle die gleichen Collections wie auf dem Server.

**In .env:**
```env
PUBLIC_POCKETBASE_URL=http://localhost:8090
```

---

## Troubleshooting

### Problem: "Connection refused" beim Login

**Lösung:**
```bash
# Auf dem Server
systemctl status pocketbase
# Falls nicht running:
systemctl start pocketbase
```

### Problem: SSL-Zertifikat nicht verfügbar

**Lösung:**
```bash
# DNS checken
dig trainingsplaner.ttsg-ostfildern.de

# Caddy Logs ansehen
journalctl -u caddy -n 50

# Caddy neustarten
systemctl restart caddy
```

### Problem: GitHub Actions schlägt fehl

**Lösung:** Prüfe GitHub Secrets:
- `HETZNER_HOST` = Server-IP (ohne http://)
- `HETZNER_USER` = `root`
- `HETZNER_SSH_KEY` = Privater SSH-Key (komplett mit BEGIN/END)

### Problem: Deployment funktioniert, aber App zeigt Fehler

**Lösung:**
```bash
# Auf dem Server
ls -la /var/www/trainingsplaner
# Sollte index.html zeigen

# Browser-Console öffnen (F12)
# Prüfe Fehler
```

---

## Kosten-Übersicht

| Service | Kosten/Monat | Jährlich |
|---------|--------------|----------|
| Hetzner CPX21 | 15€ | 180€ |
| Domain (optional) | 1-2€ | 12-24€ |
| **Total** | **16-17€** | **~200€** |

**Vergleich zu Supabase Pro:** 25$/Monat = ~300€/Jahr 🎯

---

## Backup-Strategie

```bash
# Auf dem Server
# Backup-Script erstellen
cat > /root/backup-pocketbase.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/root/backups"
DATE=$(date +%Y-%m-%d_%H-%M)

mkdir -p $BACKUP_DIR

# PocketBase DB sichern
cp /opt/pb_data/data.db $BACKUP_DIR/pocketbase-$DATE.db

# Alte Backups löschen (älter als 30 Tage)
find $BACKUP_DIR -name "pocketbase-*.db" -mtime +30 -delete

echo "Backup erstellt: $BACKUP_DIR/pocketbase-$DATE.db"
EOF

chmod +x /root/backup-pocketbase.sh

# Cron-Job für tägliches Backup
crontab -e
# Füge hinzu:
0 3 * * * /root/backup-pocketbase.sh
```

---

## Nächste Schritte

1. ✅ **E-Mail-Benachrichtigungen** hinzufügen (PocketBase SMTP)
2. ✅ **Monitoring** einrichten (Uptime Kuma, Grafana)
3. ✅ **Weitere Apps** auf dem gleichen Server hosten
4. ✅ **Skalieren** wenn nötig (größerer Server oder Load Balancer)

---

## Support

Bei Fragen oder Problemen:
- PocketBase Docs: https://pocketbase.io/docs/
- Hetzner Docs: https://docs.hetzner.com/
- GitHub Issues in diesem Repo

**Du hast es geschafft! 🎉**

Deine App läuft jetzt auf deiner eigenen Infrastruktur in Deutschland.
