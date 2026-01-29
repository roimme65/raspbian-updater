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
- ✅ Überprüfen Sie den Code vor der Ausführung
- ✅ Verwenden Sie den `--dry-run` Modus zum Testen
- ✅ Prüfen Sie die Log-Dateien regelmäßig (`/var/log/raspbian-updater/`)
- ✅ Verwenden Sie die neueste Version
- ✅ Aktivieren Sie GitHub Actions für automatische Security-Checks

### Cronjobs
Wenn Sie Cronjobs einrichten, werden diese mit Root-Rechten ausgeführt:
- ✅ Stellen Sie sicher, dass nur autorisierte Benutzer Cronjobs ändern können
- ✅ Logs werden nach `/var/log/raspbian-updater/` geschrieben
- ✅ Überprüfen Sie regelmäßig die ausgeführten Updates
- ⚠️ Verwenden Sie `sudo crontab -l` um aktive Cronjobs zu prüfen

### Identifizierte Sicherheitsaspekte & Maßnahmen

#### 1. Shell-Injection-Schutz
**Status:** Implementiert
- Alle Befehle verwenden `subprocess` mit Listen-Argumenten (kein Shell=True)
- Input-Validierung in `install.sh` und `manage_cronjobs.sh`
- Keine unescapten User-Inputs in Shell-Befehlen

#### 2. Temporäre Dateien
**Status:** Sicher implementiert
- Verwendung von `$$` für eindeutige Temp-File Namen in Shell-Scripts
- Automatisches Aufräumen mit `rm -f` nach Verwendung
- Temp-Dateien in `.gitignore` ausgeschlossen

#### 3. Prozess-Information Zugriff
**Status:** Sicher mit Fehlerbehandlung
- `/proc` Zugriffe sind mit Try-Except Blöcken geschützt
- Fallback-Mechanismen für fehlende Prozess-Informationen
- Keine Fehler bei unzugänglichen Prozessen

#### 4. Datei-Berechtigungen
**Status:** Korrekt konfiguriert
- Log-Verzeichnis: `755` (nur Root kann schreiben)
- Scripts: `755` (ausführbar, aber nicht modifizierbar)
- Log-Dateien: Nur von Root lesbar

### Datenverarbeitung
- ✅ Das Tool speichert keine sensiblen Daten
- ✅ Log-Dateien enthalten nur Paketinformationen und Systemausgaben
- ✅ JSON-Status-Logs enthalten nur technische Update-Informationen
- ✅ Keine Netzwerkkommunikation außer apt-Repositories
- ✅ Keine Credentials oder API-Keys erforderlich

### Systemintegrität
- ✅ Das Tool führt nur offizielle apt-Befehle aus
- ✅ Keine Modifikation von Systemdateien außerhalb des apt-Systems
- ✅ Alle Aktionen werden geloggt
- ✅ Exit-Codes ermöglichen Fehlerüberwachung
- ✅ `DEBIAN_FRONTEND=noninteractive` verhindert interaktive Prompts

### Desktop-Benachrichtigungen
**Sicherheit:** Niedrige Priorität, nur Informationszwecke
- Verwendet `notify-send` (optional, nicht kritisch)
- Keine sensiblen Informationen in Benachrichtigungen
- Läuft im Kontext des Desktop-Benutzers
- Timeout von 5 Sekunden verhindert Blockierung

### Automatische Sicherheitsprüfungen (CI/CD)

Das Repository verwendet GitHub Actions für automatische Security-Checks:

#### 1. Security Workflow (`.github/workflows/security.yml`)
- **Bandit:** Python Security Linter (täglich um 2:00 UTC)
- **ShellCheck:** Bash Script Analyse
- **Dependency Review:** Prüfung von Abhängigkeiten bei Pull Requests

#### 2. Quality Workflow (`.github/workflows/quality.yml`)
- **Flake8:** Python Code Style & Error Detection
- **Pylint:** Erweiterte Python Code-Analyse
- **Syntax Checks:** Bash und Python Syntax-Validierung
- **Version Check:** Konsistenz-Prüfung der VERSION Datei

#### 3. Release Workflow (`.github/workflows/release.yml`)
- Automatische Release-Erstellung bei Version-Tags
- Validierung von VERSION und Release-Notes
- Signierte Release-Artefakte

## Public Repository Überlegungen

Da dieses Repository **öffentlich auf GitHub** ist:

### ✅ Was ist sicher
- Source Code kann von jedem eingesehen werden → Transparenz
- Keine Credentials oder Secrets im Code
- Alle sensiblen Daten in `.gitignore` ausgeschlossen
- GitHub Actions für automatische Security-Scans
- Community kann Sicherheitsprobleme melden

### ⚠️ Best Practices für Nutzer
1. **Fork & Review:** Forken Sie das Repo und reviewen Sie den Code vor Verwendung
2. **Signed Commits:** Verifizieren Sie signierte Commits
3. **Release Tags:** Nutzen Sie offizielle Release-Tags statt `main` Branch
4. **Security Advisories:** Abonnieren Sie GitHub Security Advisories
5. **Zwei-Faktor-Auth:** Verwenden Sie 2FA wenn Sie zum Repo beitragen

### 🔒 Für Maintainer/Contributors
- **Niemals committen:** Credentials, API-Keys, Private Keys
- **Secrets Management:** Verwenden Sie GitHub Secrets für CI/CD
- **Branch Protection:** Main Branch mit Review-Requirements schützen
- **Signed Commits:** GPG-signierte Commits verwenden
- **Security Scans:** Lokale Bandit/ShellCheck Scans vor Push

## Reporting a Vulnerability

Wenn Sie eine Sicherheitslücke im Raspbian Trixie Auto-Updater entdecken, melden Sie diese bitte:

### Kontakt
- **E-Mail:** roimme@mailbox.org (für kritische Sicherheitsprobleme)
- **GitHub Security Advisories:** [Privates Security Advisory](https://github.com/roimme65/raspbian-updater/security/advisories/new)
- **GitHub Issues:** https://github.com/roimme65/raspbian-updater/issues (für nicht-kritische Probleme)

### Was Sie erwarten können
1. **Bestätigung:** Innerhalb von 48 Stunden nach Meldung
2. **Bewertung:** Analyse der Schwere und Auswirkung innerhalb von 5 Werktagen
3. **Updates:** Regelmäßige Statusupdates während der Bearbeitung
4. **Fix:** 
   - Kritische Probleme: Patch innerhalb von 7 Tagen
   - Moderate Probleme: Patch im nächsten Release
   - Geringe Probleme: Wird dokumentiert und geplant
5. **Anerkennung:** Credit in Release-Notes (falls gewünscht)

### Informationen für Ihre Meldung
Bitte fügen Sie hinzu:
- ✅ Beschreibung der Sicherheitslücke
- ✅ Schritte zur Reproduktion
- ✅ Betroffene Versionen
- ✅ Mögliche Auswirkungen (CVSS Score falls möglich)
- ✅ Vorgeschlagene Lösung (falls vorhanden)
- ✅ PoC (Proof of Concept) Code falls verfügbar

### Verantwortungsvolle Offenlegung
Wir bitten um:
- ⏰ Keine öffentliche Bekanntgabe vor einem Fix (90 Tage Koordinierungszeitraum)
- 🕐 Zeit für Entwicklung und Testing eines Patches
- 📢 Koordinierte Veröffentlichung von Sicherheitsinformationen
- 🤝 Zusammenarbeit bei der Behebung

### Schweregrad-Klassifizierung

| Schweregrad | Beschreibung | Beispiel |
|-------------|--------------|----------|
| **Kritisch** | Remote Code Execution, Privilege Escalation | Shell-Injection mit Root-Rechten |
| **Hoch** | Lokale Code-Ausführung, Daten-Verlust | Unsichere Temp-File Erstellung |
| **Mittel** | Information Disclosure, DoS | Log-Files mit sensiblen Daten |
| **Niedrig** | Code-Qualität, nicht exploitbar | Fehlende Input-Validierung ohne Auswirkung |

## Security Changelog

### v1.0.6 (2025-01-29)
- ✅ GitHub Actions Security Workflows hinzugefügt
- ✅ Erweiterte .gitignore für sensible Dateien
- ✅ Security Policy aktualisiert mit Public-Repo Considerations
- ✅ Automatische Security-Scans (Bandit, ShellCheck)

### v1.0.x (Frühere Versionen)
- ✅ Shell-Injection-Schutz implementiert
- ✅ Sichere Temp-File Handhabung
- ✅ Desktop-Notification Sicherheit
- ✅ Prozess-Information Fehlerbehandlung

## Nützliche Tools für Security-Testing

### Lokale Tests
```bash
# Python Security Scan
pip install bandit
bandit -r raspbian_autoupdater.py

# Shell Script Analyse
sudo apt install shellcheck
shellcheck install.sh uninstall.sh manage_cronjobs.sh

# Python Code Quality
pip install flake8 pylint
flake8 raspbian_autoupdater.py
pylint raspbian_autoupdater.py
```

### Monitoring
```bash
# Log-Überwachung
tail -f /var/log/raspbian-updater/*.log

# Cronjob-Überprüfung
sudo crontab -l | grep raspbian

# Prozess-Monitoring
ps aux | grep raspbian
```

---

**Vielen Dank für Ihre Unterstützung bei der Sicherheit dieses Projekts! 🔒**

Gemeinsam können wir ein sicheres und zuverlässiges Update-System für alle Nutzer gewährleisten.
