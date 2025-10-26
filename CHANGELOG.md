# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

## [1.0.5] - 2025-10-26

### Hinzugefügt
- 🐍 **Python-Versions-Prüfung** in install.sh
  - Prüft ob Python 3 installiert ist
  - Prüft ob Python Version >= 3.9
  - Klare Fehlermeldungen bei fehlenden Voraussetzungen
  - Installationsanleitung für ältere Systeme
  - Verhindert Silent-Failures bei Installation
  - Exit-Code 1 wenn Voraussetzungen nicht erfüllt

### Geändert
- 🔧 **Installation** bricht früh ab bei fehlender oder zu alter Python-Version

## [1.0.4] - 2025-10-25

### Hinzugefügt
- 🔔 **Desktop-Benachrichtigungen** via notify-send
  - Kritische Warnung (rot) bei erforderlichem Neustart
  - Erfolgs-Benachrichtigung (grün) nach Updates
  - Info-Benachrichtigung (blau) wenn keine Updates verfügbar
  - Automatische Erkennung von DISPLAY und DBUS_SESSION_BUS_ADDRESS
  - Funktioniert mit sudo und in Cronjobs
  - Benachrichtigt alle aktiven GUI-Sessions
- 📦 **Automatische Installation** von Desktop-Benachrichtigungs-Tools
  - libnotify-bin wird in install.sh installiert
  - notification-daemon wird in install.sh installiert
  - **notification-daemon Autostart** automatisch eingerichtet
  - Startet notification-daemon sofort nach Installation
  - Funktioniert nach Neustart automatisch
  - Hinweis für Benutzer über GUI-Funktionalität
- 🗑️ **uninstall.sh erweitert** für Benachrichtigungs-Komponenten
  - Entfernt notification-daemon Autostart-Datei
  - Optional: Deinstalliert libnotify-bin und notification-daemon
  - Stoppt laufende notification-daemon Prozesse
  - Bereinigt für alle Benutzer

### Behoben
- 🐛 **Seitlicher Versatz in apt-Ausgabe**
  - apt-get verwendet nun -q (quiet) Option
  - DEBIAN_FRONTEND=noninteractive für alle apt-Befehle
  - -o Dpkg::Use-Pty=0 unterdrückt dpkg-Fortschrittsanzeige
  - Saubere, lineare Ausgabe ohne Versatz
- 🔧 **notification-daemon startet nicht nach Neustart**
  - Autostart-Datei wird automatisch erstellt
  - Funktioniert für SUDO_USER mit korrekten Berechtigungen
  - Benachrichtigungen funktionieren sofort nach System-Neustart

### Verbessert
- 📝 **Dokumentation** um Desktop-Benachrichtigungen erweitert
- 🔧 **Robustheit** bei fehlenden GUI-Komponenten

## [1.0.3] - 2025-10-24

### Hinzugefügt
- 🗑️ **Deinstallations-Script** (`uninstall.sh`)
  - Entfernt Symlink `/usr/local/bin/raspbian-autoupdater`
  - Entfernt alle Cronjobs (root und Benutzer)
  - Prüft und entfernt Systemd Timer
  - Optional: Löscht Log-Verzeichnis nach Rückfrage
  - Interaktive Bestätigungen für alle Aktionen

### Behoben
- 🐛 **Paket-Erkennung für deutsche apt-Ausgabe**
  - Parser unterstützt nun "Die folgenden Pakete werden aktualisiert" Format
  - Extrahiert Paketnamen aus deutscher und englischer apt-Ausgabe
  - Sammelt Versionsinformationen aus "Entpacken von" Zeilen
  - Zeigt korrekte Anzahl aktualisierter Pakete in Zusammenfassung
- 🎨 **Einheitliche Formatierung der Paketliste**
  - Paketliste wird nun mit `print_status()` ausgegeben
  - Keine seitliche Versetzung mehr in der Ausgabe
  - Konsistente Farbgebung (blau) für alle Paketeinträge
  - Automatisches Logging aller Paketausgaben

### Verbessert
- 📝 **Dokumentation** in README.md um Deinstallation erweitert

## [1.0.2] - 2025-10-24

### Hinzugefügt
- 📋 **GitHub Issue Templates** angepasst für Raspbian Auto-Updater
  - Bug Report Template auf Deutsch mit relevanten Feldern
  - Feature Request Template auf Deutsch mit Komponenten-Auswahl
- 💬 **GitHub Discussions Template** auf Deutsch erstellt
  - Willkommensnachricht mit Community-Richtlinien
  - Kategorien für Q&A, Ideen, Show & Tell
  - Starter-Fragen für neue Mitglieder
- 🏷️ **Labels** für Issue Templates (bug, enhancement)
- 📝 **Titel-Präfixe** für bessere Übersicht ([BUG], [FEATURE])

### Verbessert
- 🇩🇪 **Deutsche Sprache** in allen Community-Templates
- 📊 **Strukturierte Formulare** für Bug Reports und Feature Requests
- 🎯 **Raspbian-spezifische Felder** (Hardware, OS, Cronjobs, Logs)
- 🤝 **Mitarbeits-Optionen** in Feature Requests

## [1.0.1] - 2025-10-24

### Hinzugefügt
- 📁 **Releases-Verzeichnis** mit strukturierten Release Notes
- 🛡️ **Umfassende SECURITY.md** mit Sicherheitsrichtlinien
- 🔗 **GitHub Badges** in README (License, Python Version, Release)
- 🏷️ **Statische Badges** für bessere Kompatibilität
- 📚 **Verbesserte Dokumentation** mit besserer Struktur
- 🤝 **Contribution Guidelines** in README
- 🔗 **Nützliche Links** zu Repository, Issues, Releases

### Geändert
- ✨ **README komplett überarbeitet** mit Emojis und besserer Struktur
- 📖 **Feature-Beschreibungen** deutlich erweitert
- 🔧 **Installationspfade** korrigiert und vereinheitlicht
- 📊 **Paket-Liste Display** in Dokumentation hervorgehoben
- 🎨 **Markdown-Formatierung** verbessert

### Verbessert
- 🔒 **Sicherheitsrichtlinien** detailliert dokumentiert
- 📝 **Beispiel-Ausgaben** aktualisiert und erweitert
- 🛠️ **Systemd Service Beispiele** mit korrekten Pfaden
- 📦 **JSON-Log Struktur** vollständig dokumentiert

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

[1.0.2]: https://github.com/roimme65/raspbian-updater/releases/tag/v1.0.2
[1.0.1]: https://github.com/roimme65/raspbian-updater/releases/tag/v1.0.1
[1.0.0]: https://github.com/roimme65/raspbian-updater/releases/tag/v1.0.0
