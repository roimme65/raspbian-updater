# Raspbian Trixie Auto-Updater

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![Version](https://img.shields.io/badge/version-1.1.1-green.svg)](https://github.com/roimme65/raspbian-updater/releases)
[![Platform](https://img.shields.io/badge/platform-Raspbian%20Trixie-red.svg)](https://www.raspberrypi.com/)

Ein vollständiger Python-basierter Auto-Updater für Raspbian/Debian Trixie mit detaillierter Statusanzeige, Logging und Cronjob-Verwaltung.

## 🌟 Features

### 🔄 Automatisches Update-System
- ✅ Vollautomatische System-Updates mit einem Befehl
- 🔁 Kompletter Update-Zyklus: `update` → `upgrade` → `dist-upgrade` → `autoremove` → `autoclean`
- ⚡ Quick-Modus für schnelle Updates (ohne dist-upgrade)
- 🧪 Dry-Run Modus zum sicheren Testen

### 📊 Statusanzeige & Logging
- 🎨 Echtzeit-Statusanzeige mit ANSI-Farbcodierung
- 📝 Detailliertes Logging (Text + JSON)
- ⏱️ Zeitmessung für jeden einzelnen Schritt
- 📦 **Paket-Liste mit Versionsnummern** in der Update-Zusammenfassung
- 💾 Strukturierte JSON-Logs für automatisierte Auswertung

### 🛠️ Cronjob-Verwaltung
- 📅 Interaktives Verwaltungsmenü (`manage_cronjobs.sh`)
- 👀 Anzeige aktueller Cronjobs mit Zeitplan-Interpretation
- 📋 Fertige Vorlagen für häufige Zeitpläne
- 📊 Log-Anzeige mit Zusammenfassungen
- 📖 Cron-Syntax Hilfe

### 🔒 Sicherheit & Zuverlässigkeit
- 🔐 Root-Rechte-Prüfung
- 🔄 Automatische Neustart-Erkennung
- 🛡️ Saubere Fehlerbehandlung
- ⌨️ STRG+C Interrupt-Unterstützung
- 🔢 Exit-Codes für Automatisierung

### 🔔 Desktop-Benachrichtigungen
- 🔴 **Kritische Warnung** bei erforderlichem Neustart
- 🟢 **Erfolgs-Meldung** nach Updates
- 🔵 **Info** wenn keine Updates verfügbar
- 📱 Funktioniert auch bei Cronjob-Ausführung
- 🎯 Automatische Erkennung von GUI-Sessions
- ⚙️ **Autostart automatisch eingerichtet** - funktioniert nach Neustart

## 📦 Installation

### Schnellinstallation

```bash
# Repository klonen
git clone https://github.com/roimme65/raspbian-updater.git
cd raspbian-updater

# Installation mit automatischer Einrichtung
sudo ./install.sh
```

Das Installations-Script:
- ✅ Setzt Ausführungsrechte
- ✅ Installiert `libnotify-bin` und `notification-daemon`
- ✅ Richtet `notification-daemon` Autostart ein (nach Neustart automatisch)
- ✅ Erstellt Log-Verzeichnis (`/var/log/raspbian-updater/`)
- ✅ Erstellt Symlink (`/usr/local/bin/raspbian-autoupdater`)
- ✅ Bietet optionale Cronjob-Einrichtung an

### Deinstallation

```bash
# Vollständige Deinstallation
sudo ./uninstall.sh
```

Das Deinstallations-Script entfernt:
- ✅ Symlink `/usr/local/bin/raspbian-autoupdater`
- ✅ Alle Cronjobs für raspbian-autoupdater
- ✅ `notification-daemon` Autostart-Datei
- ✅ Optional: `libnotify-bin` und `notification-daemon` Pakete (nach Rückfrage)
- ✅ Optional: Log-Verzeichnis (nach Rückfrage)

### Manuelle Installation

```bash
# Ausführbar machen
chmod +x raspbian_autoupdater.py

# Optional: Symlink erstellen
sudo ln -s "$(pwd)/raspbian_autoupdater.py" /usr/local/bin/raspbian-autoupdater
```

## 🚀 Verwendung

### Vollständiges Update

```bash
sudo raspbian-autoupdater
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
sudo raspbian-autoupdater --quick
```

### Dry-Run Modus

Um zu sehen, was ausgeführt würde ohne Änderungen vorzunehmen:

```bash
raspbian-autoupdater --dry-run
```

### Benutzerdefiniertes Log-Verzeichnis

```bash
sudo raspbian-autoupdater --log-dir /custom/path/logs
```

### Cronjob-Verwaltung

```bash
# Interaktives Menü
sudo ./manage_cronjobs.sh

# Schnellzugriff: Zeige Cronjobs
./manage_cronjobs.sh --show

# Schnellzugriff: Zeige Logs
./manage_cronjobs.sh --logs
```

## 📋 Ausgabe

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
  "upgraded_packages": [
    "python3-pip 23.0.1+dfsg-1 → 24.0+dfsg-1",
    "nginx 1.24.0-2 → 1.24.0-3"
  ],
  "package_count": 23,
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

## ⏰ Automatisierung mit Cron

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
ExecStart=/usr/local/bin/raspbian-autoupdater
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

## 📊 Update-Zusammenfassung

Nach jedem Update erhalten Sie eine detaillierte Zusammenfassung mit:
- ⏱️ Gesamtdauer des Updates
- 📦 **Liste aller aktualisierten Pakete mit Versionsnummern**
- 🔄 Neustart-Benachrichtigung (falls erforderlich)
- 📝 Pfad zur Log-Datei

Beispiel:
```
======================================================================
                    Update-Zusammenfassung
======================================================================

2025-10-24 10:25:45 Gesamtdauer: 615.53 Sekunden (10.26 Minuten)

📦 Aktualisierte Pakete (23):
    1. python3-pip 23.0.1+dfsg-1 → 24.0+dfsg-1
    2. nginx 1.24.0-2 → 1.24.0-3
    3. openssh-server 1:9.6p1-3 → 1:9.7p1-1
    ...

✓ Kein Neustart erforderlich.
```

## 🔒 Sicherheit

Das Skript prüft automatisch, ob ein Neustart erforderlich ist (z.B. nach Kernel-Updates) und zeigt eine entsprechende Warnung an.

Siehe [SECURITY.md](SECURITY.md) für Details zur Sicherheitsrichtlinie.

## 🛠️ Fehlerbehandlung

- Bei Fehlern werden Details geloggt
- Exit-Codes geben Auskunft über Erfolg/Misserfolg
- STRG+C Abbruch wird sauber behandelt
- JSON-Logs enthalten Fehlerdetails

## 📋 Systemanforderungen

### Kompatibilität
- ✅ Raspbian Trixie (Debian 13)
- ✅ Debian Trixie
- ✅ Python 3.9+
- ⚠️ Erfordert Root-Rechte (außer im Dry-Run Modus)

### Anforderungen
- Python 3 (Standard auf Raspbian)
- Root-Zugriff für System-Updates
- Keine externen Python-Bibliotheken erforderlich (nur Standard-Library)

## 🔧 Troubleshooting

### Falsche Kernel-Warnung auf Raspberry Pi 5

**Problem:**
Nach Updates zeigt `needrestart` möglicherweise eine falsche Warnung:
```
Ausstehendes Kernel-Upgrade!
  
  Laufende Kernel-Version:
    6.12.47+rpt-rpi-2712
  
  Diagnose:
    Die aktuelle Kernel-Version ist nicht die erwartete Version 6.12.47+rpt-rpi-v8.
```

**Ursache:**
Das Raspberry Pi 5 verwendet den **BCM2712 SoC** und benötigt einen speziellen Kernel (`rpi-2712`), nicht den generischen `rpi-v8` Kernel. Die Standardkonfiguration von `needrestart` erkennt dies nicht korrekt.

**Kernel-Varianten:**
- `rpi-2712`: Für Raspberry Pi 5 (BCM2712 SoC) ✅ **Korrekt für Pi 5**
- `rpi-v8`: Für ältere Modelle (Pi 3B+, Pi 4, Pi 400)

**Lösung:**
Erstellen Sie eine spezifische `needrestart`-Konfiguration für das Pi 5:

```bash
sudo tee /etc/needrestart/conf.d/raspberrypi5.conf > /dev/null << 'EOF'
# Raspberry Pi 5 specific needrestart configuration
# The Pi 5 uses the BCM2712 SoC and requires the kernel_2712.img kernel variant

# Filter kernel image filenames to match the Pi 5 kernel variant
$nrconf{kernelfilter} = qr(kernel_2712\.img);
EOF
```

**Verifizierung:**
Nach der Konfiguration sollte `needrestart` keinen Kernel-Neustart mehr fälschlicherweise anfordern:

```bash
sudo needrestart -b
```

Erwartete Ausgabe:
```
NEEDRESTART-VER: 3.11
NEEDRESTART-KCUR: 6.12.47+rpt-rpi-2712
NEEDRESTART-KSTA: 0
```

`NEEDRESTART-KSTA: 0` bedeutet: Kein Kernel-Neustart erforderlich ✅

**Hinweis:** Diese Konfiguration muss nur einmal erstellt werden und bleibt bei System-Updates erhalten.

## 🤝 Beitragen

Feedback, Bug-Reports und Pull Requests sind willkommen!

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/roimme65/raspbian-updater/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/roimme65/raspbian-updater/discussions)
- 🔀 **Pull Requests**: Gerne Verbesserungen einreichen

## 📝 Changelog

Siehe [CHANGELOG.md](CHANGELOG.md) für alle Versionsänderungen.

## 📄 Lizenz

Dieses Projekt ist unter der [MIT License](LICENSE) lizenziert - frei verwendbar für private und kommerzielle Zwecke.

## 👤 Autor

Entwickelt von [roimme65](https://github.com/roimme65) für Raspbian Trixie System-Wartung.

## 🔗 Links

- **Repository**: https://github.com/roimme65/raspbian-updater
- **Issues**: https://github.com/roimme65/raspbian-updater/issues
- **Releases**: https://github.com/roimme65/raspbian-updater/releases
- **Security**: [SECURITY.md](SECURITY.md)

