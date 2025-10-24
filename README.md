# Raspbian Trixie Auto-Updater

Ein Python-basierter Auto-Updater für Raspbian/Debian Trixie mit detaillierter Statusanzeige und Logging-Funktionalität.

## Features

- ✅ Vollautomatische System-Updates
- 📊 Echtzeit-Statusanzeige mit Farbcodierung
- 📝 Detailliertes Logging (Text + JSON)
- ⏱️ Zeitmessung für jeden Schritt
- 🔒 Root-Rechte-Prüfung
- 🧪 Dry-Run Modus zum Testen
- ⚡ Schnellmodus für schnelle Updates
- 🔄 Automatische Neustart-Erkennung

## Installation

```bash
# Repository klonen oder Datei herunterladen
cd /media/imme/ENCRYPTSSD/daten/git/github/tools-skripte/raspbian-updater

# Ausführbar machen
chmod +x raspbian_autoupdater.py
```

## Verwendung

### Vollständiges Update

```bash
sudo ./raspbian_autoupdater.py
```

Dies führt aus:
1. `apt update` - Paketlisten aktualisieren
2. `apt upgrade` - Pakete aktualisieren
3. `apt dist-upgrade` - Distribution aktualisieren
4. `apt autoremove` - Unnötige Pakete entfernen
5. `apt autoclean` - Cache bereinigen

### Schnelles Update

Für schnelle Updates ohne dist-upgrade:

```bash
sudo ./raspbian_autoupdater.py --quick
```

### Dry-Run Modus

Um zu sehen, was ausgeführt würde ohne Änderungen vorzunehmen:

```bash
./raspbian_autoupdater.py --dry-run
```

### Benutzerdefiniertes Log-Verzeichnis

```bash
sudo ./raspbian_autoupdater.py --log-dir /home/pi/update-logs
```

## Ausgabe

Das Skript zeigt während der Ausführung:

- 🔵 **Laufende Prozesse** - in Cyan
- 🟢 **Erfolgreiche Schritte** - in Grün
- 🔴 **Fehler** - in Rot
- 🟡 **Warnungen** - in Gelb

Beispiel-Ausgabe:
```
======================================================================
           Raspbian Trixie Auto-Updater
======================================================================

2025-10-24 10:15:30 [LÄUFT] Starte: APT Update - Paketlisten aktualisieren
  Hit:1 http://deb.debian.org/debian trixie InRelease
  ...
2025-10-24 10:15:45 [ERFOLGREICH] Abgeschlossen: APT Update (Dauer: 15.32s)

2025-10-24 10:15:45 [LÄUFT] Starte: APT Upgrade - Pakete aktualisieren
  ...
```

## Log-Dateien

### Text-Logs

Detaillierte Text-Logs werden gespeichert in:
```
/var/log/raspbian-updater/update_YYYYMMDD_HHMMSS.log
```

### JSON-Status-Logs

Strukturierte Status-Informationen als JSON:
```
/var/log/raspbian-updater/update_status_YYYYMMDD_HHMMSS.json
```

Beispiel JSON-Struktur:
```json
{
  "start_time": "2025-10-24T10:15:30.123456",
  "end_time": "2025-10-24T10:25:45.654321",
  "duration_seconds": 615.53,
  "steps": [
    {
      "step": "APT Update - Paketlisten aktualisieren",
      "command": "apt-get update",
      "start_time": "2025-10-24T10:15:30.123456",
      "end_time": "2025-10-24T10:15:45.456789",
      "status": "erfolgreich",
      "duration_seconds": 15.33
    }
  ]
}
```

## Automatisierung mit Cron

Um das Skript automatisch auszuführen, fügen Sie es zu crontab hinzu:

```bash
sudo crontab -e
```

Beispiele:

```cron
# Jeden Tag um 3:00 Uhr morgens
0 3 * * * /media/imme/ENCRYPTSSD/daten/git/github/tools-skripte/raspbian-updater/raspbian_autoupdater.py

# Jeden Sonntag um 2:00 Uhr morgens
0 2 * * 0 /media/imme/ENCRYPTSSD/daten/git/github/tools-skripte/raspbian-updater/raspbian_autoupdater.py

# Schnelles Update jeden Tag um 6:00 Uhr
0 6 * * * /media/imme/ENCRYPTSSD/daten/git/github/tools-skripte/raspbian-updater/raspbian_autoupdater.py --quick
```

## Systemd Service (Optional)

Erstellen Sie einen systemd-Service für regelmäßige Updates:

```bash
sudo nano /etc/systemd/system/raspbian-autoupdate.service
```

Inhalt:
```ini
[Unit]
Description=Raspbian Auto-Updater
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/media/imme/ENCRYPTSSD/daten/git/github/tools-skripte/raspbian-updater/raspbian_autoupdater.py
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Timer erstellen:
```bash
sudo nano /etc/systemd/system/raspbian-autoupdate.timer
```

Inhalt:
```ini
[Unit]
Description=Raspbian Auto-Updater Timer
Requires=raspbian-autoupdate.service

[Timer]
OnCalendar=daily
OnCalendar=03:00
Persistent=true

[Install]
WantedBy=timers.target
```

Aktivieren:
```bash
sudo systemctl daemon-reload
sudo systemctl enable raspbian-autoupdate.timer
sudo systemctl start raspbian-autoupdate.timer

# Status prüfen
sudo systemctl status raspbian-autoupdate.timer
```

## Neustart-Erkennung

Das Skript prüft automatisch, ob ein Neustart erforderlich ist (z.B. nach Kernel-Updates) und zeigt eine entsprechende Warnung an.

## Fehlerbehandlung

- Bei Fehlern werden Details geloggt
- Exit-Codes geben Auskunft über Erfolg/Misserfolg
- STRG+C Abbruch wird sauber behandelt

## Kompatibilität

- Raspbian Trixie (Debian 13)
- Debian Trixie
- Python 3.9+
- Erfordert Root-Rechte (außer im Dry-Run Modus)

## Anforderungen

- Python 3 (Standard auf Raspbian)
- Root-Zugriff für System-Updates
- Keine externen Python-Bibliotheken erforderlich (nur Standard-Library)

## Lizenz

Open Source - Frei verwendbar

## Autor

Auto-generiert für Raspbian Trixie System-Wartung
