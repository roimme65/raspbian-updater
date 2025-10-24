# Security Policy

## Supported Versions

Die folgenden Versionen des Raspbian Trixie Auto-Updaters werden mit Sicherheitsupdates unterstützt:

| Version | Unterstützt        | Status |
| ------- | ------------------ | ------ |
| 1.0.x   | :white_check_mark: | Aktuelle stabile Version |
| < 1.0   | :x:                | Entwicklungsversionen |

## Sicherheitsüberlegungen

### Root-Rechte
Der Auto-Updater benötigt Root-Rechte (sudo) für System-Updates. Dies ist erforderlich, da `apt-get` Systemänderungen vornimmt.

**Empfohlene Sicherheitsmaßnahmen:**
- Überprüfen Sie den Code vor der Ausführung
- Verwenden Sie den `--dry-run` Modus zum Testen
- Prüfen Sie die Log-Dateien regelmäßig
- Verwenden Sie die neueste Version

### Cronjobs
Wenn Sie Cronjobs einrichten, werden diese mit Root-Rechten ausgeführt:
- Stellen Sie sicher, dass nur autorisierte Benutzer Cronjobs ändern können
- Logs werden nach `/var/log/raspbian-updater/` geschrieben
- Überprüfen Sie regelmäßig die ausgeführten Updates

### Datenverarbeitung
- Das Tool speichert keine sensiblen Daten
- Log-Dateien enthalten Paketinformationen und Systemausgaben
- JSON-Status-Logs enthalten nur technische Update-Informationen
- Keine Netzwerkkommunikation außer apt-Repositories

### Systemintegrität
- Das Tool führt nur offizielle apt-Befehle aus
- Keine Modifikation von Systemdateien außerhalb des apt-Systems
- Alle Aktionen werden geloggt
- Exit-Codes ermöglichen Fehlerüberwachung

## Reporting a Vulnerability

Wenn Sie eine Sicherheitslücke im Raspbian Trixie Auto-Updater entdecken, melden Sie diese bitte:

### Kontakt
- **E-Mail**: roimme@mailbox.org
- **GitHub Issues**: https://github.com/roimme65/raspbian-updater/issues (für nicht-kritische Probleme)
- **GitHub Security Advisories**: Für kritische Sicherheitsprobleme

### Was Sie erwarten können
1. **Bestätigung**: Innerhalb von 48 Stunden nach Meldung
2. **Bewertung**: Analyse der Schwere und Auswirkung innerhalb von 5 Werktagen
3. **Updates**: Regelmäßige Statusupdates während der Bearbeitung
4. **Fix**: 
   - Kritische Probleme: Patch innerhalb von 7 Tagen
   - Moderate Probleme: Patch im nächsten Release
   - Geringe Probleme: Wird dokumentiert und geplant

### Informationen für Ihre Meldung
Bitte fügen Sie hinzu:
- Beschreibung der Sicherheitslücke
- Schritte zur Reproduktion
- Betroffene Versionen
- Mögliche Auswirkungen
- Vorgeschlagene Lösung (falls vorhanden)

### Verantwortungsvolle Offenlegung
Wir bitten um:
- Keine öffentliche Bekanntgabe vor einem Fix
- Zeit für Entwicklung und Testing eines Patches
- Koordinierte Veröffentlichung von Sicherheitsinformationen

Vielen Dank für Ihre Unterstützung bei der Sicherheit dieses Projekts!
