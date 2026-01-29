# Contributing zu Raspbian Auto-Updater

Vielen Dank für dein Interesse, zu diesem Projekt beizutragen! 🎉

## 📋 Inhaltsverzeichnis

- [Code of Conduct](#code-of-conduct)
- [Wie kann ich beitragen?](#wie-kann-ich-beitragen)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Code Style Guidelines](#code-style-guidelines)
- [Security Policy](#security-policy)
- [Release Process](#release-process)

## 🤝 Code of Conduct

Dieses Projekt verpflichtet sich zu einem offenen und einladenden Umfeld. Wir erwarten von allen Beteiligten:

- ✅ Respektvolle und konstruktive Kommunikation
- ✅ Akzeptanz unterschiedlicher Perspektiven
- ✅ Fokus auf das Beste für die Community
- ❌ Keine Belästigung oder diskriminierendes Verhalten

## 🎯 Wie kann ich beitragen?

### Bugs melden

Wenn du einen Bug findest:

1. Prüfe [Issues](https://github.com/roimme65/raspbian-updater/issues), ob das Problem schon gemeldet wurde
2. Öffne ein neues Issue mit dem Template "Bug Report"
3. Beschreibe das Problem detailliert:
   - Was hast du erwartet?
   - Was ist tatsächlich passiert?
   - Schritte zur Reproduktion
   - System-Informationen (OS, Python-Version, etc.)

### Features vorschlagen

Hast du eine Idee für ein neues Feature?

1. Öffne ein Issue mit dem Template "Feature Request"
2. Beschreibe:
   - Das Problem, das gelöst werden soll
   - Deine vorgeschlagene Lösung
   - Alternativen, die du in Betracht gezogen hast
3. Warte auf Feedback vom Maintainer

### Code beitragen

1. Forke das Repository
2. Erstelle einen Feature-Branch: `git checkout -b feature/amazing-feature`
3. Committe deine Änderungen: `git commit -m 'feat: Add amazing feature'`
4. Push den Branch: `git push origin feature/amazing-feature`
5. Öffne einen Pull Request

## 🛠️ Development Setup

### Voraussetzungen

- Linux-System (Raspbian/Debian bevorzugt)
- Python 3.9+
- Git
- Root-Zugriff für Tests
- Optional: `gh` CLI für Releases

### Repository klonen

```bash
git clone https://github.com/roimme65/raspbian-updater.git
cd raspbian-updater
```

### Development Tools installieren

```bash
# Python Linting Tools
pip install flake8 pylint bandit black

# Shell Linting
sudo apt install shellcheck

# GitHub CLI (optional)
sudo apt install gh
```

### Testen

```bash
# Python Syntax Check
python3 -m py_compile raspbian_autoupdater.py

# Dry-Run Test
python3 raspbian_autoupdater.py --dry-run

# Mit Root-Rechten (auf Test-System!)
sudo python3 raspbian_autoupdater.py --dry-run

# Bash Script Syntax
bash -n install.sh
bash -n uninstall.sh
bash -n manage_cronjobs.sh

# ShellCheck
shellcheck install.sh uninstall.sh manage_cronjobs.sh
```

### Security Scans

```bash
# Python Security Scan
bandit -r raspbian_autoupdater.py

# Detaillierter Report
bandit -r raspbian_autoupdater.py -f json -o bandit-report.json

# Shell Script Analysis
shellcheck --severity=warning install.sh
```

## 🔄 Pull Request Process

### 1. Branch-Namenskonvention

- `feature/feature-name` - Neue Features
- `fix/bug-description` - Bugfixes
- `docs/description` - Dokumentations-Änderungen
- `security/issue-description` - Security-Fixes
- `refactor/description` - Code-Refactoring

### 2. Commit-Messages

Folge [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: Add desktop notification support
fix: Resolve cron timing issue
docs: Update installation instructions
security: Fix shell injection vulnerability
refactor: Improve error handling
```

**Format:**
```
<type>: <description>

[optional body]

[optional footer]
```

**Typen:**
- `feat`: Neues Feature
- `fix`: Bugfix
- `docs`: Dokumentation
- `security`: Security-Fix
- `refactor`: Code-Refactoring
- `test`: Tests
- `chore`: Wartungsarbeiten

### 3. Pull Request Checklist

Bevor du einen PR öffnest, stelle sicher:

- [ ] Code folgt den Style Guidelines
- [ ] Alle Tests bestehen
- [ ] Neue Features sind dokumentiert
- [ ] CHANGELOG.md aktualisiert (bei größeren Änderungen)
- [ ] Security-Scans zeigen keine Probleme
- [ ] Branch ist aktuell mit `main`

### 4. PR-Beschreibung Template

```markdown
## Beschreibung
Was ändert dieser PR?

## Motivation
Warum ist diese Änderung notwendig?

## Art der Änderung
- [ ] Bugfix
- [ ] Neues Feature
- [ ] Breaking Change
- [ ] Dokumentation

## Tests
Wie wurde getestet?

## Checklist
- [ ] Code folgt Style Guidelines
- [ ] Selbst-Review durchgeführt
- [ ] Kommentare für komplexe Bereiche hinzugefügt
- [ ] Dokumentation aktualisiert
- [ ] Keine neuen Warnungen
```

## 🎨 Code Style Guidelines

### Python

```python
# PEP 8 Style Guide befolgen
# Max Line Length: 100 Zeichen (flexibel)

# Type Hints verwenden
def function_name(param: str, count: int) -> bool:
    """Docstring mit Beschreibung, Args und Returns"""
    pass

# Klassen-Docstrings
class MyClass:
    """Beschreibung der Klasse"""
    
    def method(self):
        """Methoden-Beschreibung"""
        pass
```

**Tools:**
```bash
# Auto-Formatting
black raspbian_autoupdater.py

# Linting
flake8 raspbian_autoupdater.py
pylint raspbian_autoupdater.py
```

### Bash

```bash
# Immer set -e am Anfang
set -e

# Variablen in Quotes
echo "$MY_VAR"

# Funktionen dokumentieren
# Beschreibung der Funktion
function_name() {
    local param=$1
    # Implementation
}

# ShellCheck-Warnungen beheben
shellcheck script.sh
```

### Dokumentation

- Markdown für alle Docs
- Deutsche Sprache für User-Dokumentation
- Englische Commits für internationale Audience
- Code-Kommentare auf Deutsch

## 🔒 Security Policy

### Security-Fixes

Für Security-Probleme:

1. **NICHT** öffentlich im Issue-Tracker posten
2. E-Mail an: roimme@mailbox.org
3. Oder GitHub Security Advisory erstellen
4. Warte auf Antwort (innerhalb 48h)

Siehe [SECURITY.md](SECURITY.md) für Details.

### Security-Checks vor PR

```bash
# Bandit Scan
bandit -r raspbian_autoupdater.py

# ShellCheck
shellcheck install.sh uninstall.sh manage_cronjobs.sh

# Manual Review
# - Keine hardcoded Credentials
# - Keine Shell-Injection Risiken
# - Input-Validierung vorhanden
# - Fehlerbehandlung implementiert
```

## 📦 Release Process

### Für Maintainer

```bash
# 1. Alle Changes commiten
git add .
git commit -m "feat: Add new feature"

# 2. Release erstellen
./scripts/create-release.sh [major|minor|patch]

# 3. Release-Notes editieren (falls nicht --auto)
nano releases/vX.Y.Z.md

# 4. Finalisieren
./scripts/create-release.sh [major|minor|patch]
```

**Automatisch:**
- VERSION Datei wird aktualisiert
- README Badge wird aktualisiert
- Release-Notes werden generiert
- CHANGELOG.md wird aktualisiert
- Git Tag wird erstellt
- GitHub Release wird erstellt (falls gh CLI)

Siehe [scripts/README.md](scripts/README.md) für Details.

## 🌍 Internationalisierung

Aktuell ist das Projekt auf **Deutsch** fokussiert, da die Zielgruppe hauptsächlich deutschsprachig ist.

**Wenn du bei i18n helfen möchtest:**
1. Öffne ein Issue für Diskussion
2. Schlage eine Implementierung vor
3. Beachte: CLI-Output, Logs und Benachrichtigungen müssen übersetzt werden

## 💡 Hilfreiche Links

- [GitHub Issues](https://github.com/roimme65/raspbian-updater/issues)
- [Pull Requests](https://github.com/roimme65/raspbian-updater/pulls)
- [Releases](https://github.com/roimme65/raspbian-updater/releases)
- [Security Policy](SECURITY.md)
- [Security Audit](SECURITY-AUDIT.md)
- [Scripts Documentation](scripts/README.md)

## 🙏 Anerkennung

Alle Contributors werden in den Release-Notes erwähnt (falls gewünscht).

Du kannst auch in der README unter "Contributors" aufgeführt werden durch:

```bash
# Automatisch via GitHub
# Contributors werden automatisch angezeigt unter:
# https://github.com/roimme65/raspbian-updater/graphs/contributors
```

## 📧 Kontakt

- **GitHub Issues:** Für Bugs und Features
- **E-Mail:** roimme@mailbox.org (für Security-Issues)
- **Discussions:** Coming soon

---

**Vielen Dank für deine Beiträge! 🚀**

Zusammen machen wir Raspbian Auto-Updater besser für alle!
