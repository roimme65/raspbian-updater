# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

## [1.0.0] - 2025-10-24

### Hinzugefügt
- 🚀 **Initiales Release des Raspbian Trixie Auto-Updaters**
- ✨ Python-basierter Auto-Updater mit detaillierter Statusanzeige
- 📊 Echtzeit-Fortschrittsanzeige mit ANSI-Farbcodierung
- 📝 Vollständiges Logging-System:
  - Text-Logs mit allen Ausgaben
  - JSON-Status-Logs für automatisierte Auswertung
  - Zeitmessung für jeden Schritt
- 🔄 Kompletter Update-Zyklus:
  - `apt update` - Paketlisten aktualisieren
  - `apt upgrade` - Pakete aktualisieren
  - `apt dist-upgrade` - Distribution aktualisieren
  - `apt autoremove` - Unnötige Pakete entfernen
  - `apt autoclean` - Cache bereinigen
- 📦 Anzeige der aktualisierten Pakete mit Versionsnummern in der Zusammenfassung
- 🧪 Dry-Run Modus zum Testen ohne Systemänderungen
- ⚡ Quick-Modus für schnelle Updates (ohne dist-upgrade)
- 🔒 Root-Rechte-Prüfung
- 🔄 Automatische Neustart-Erkennung nach Kernel-Updates
- 🛠️ **Cronjob-Verwaltungsskript** (`manage_cronjobs.sh`):
  - Interaktives Menü zur Verwaltung
  - Anzeige aktueller Cronjobs mit Zeitplan-Interpretation
  - Vorlagen für häufige Zeitpläne
  - Log-Anzeige mit Zusammenfassung
  - Test-Ausführung
  - Cron-Syntax Hilfe
- 📥 **Installations-Script** (`install.sh`):
  - Automatische Installation und Einrichtung
  - Symlink-Erstellung
  - Log-Verzeichnis-Erstellung
  - Optionale Cronjob-Einrichtung
- 📖 Vollständige Dokumentation mit Beispielen
- 🎯 Kompatibilität mit Raspbian Trixie (Debian 13)

### Technische Details
- Python 3.9+ kompatibel
- Nur Standard-Bibliotheken (keine externen Abhängigkeiten)
- Exit-Codes für Automatisierung
- Saubere Fehlerbehandlung
- STRG+C Interrupt-Unterstützung

### Verwendung
```bash
# Installation
sudo ./install.sh

# Vollständiges Update
sudo raspbian-autoupdater

# Schnelles Update
sudo raspbian-autoupdater --quick

# Test-Modus
raspbian-autoupdater --dry-run

# Cronjob-Verwaltung
sudo ./manage_cronjobs.sh
```

### Lizenz
- MIT License hinzugefügt
- Open Source und frei verwendbar

[1.0.0]: https://github.com/roimme65/raspbian-updater/releases/tag/v1.0.0
