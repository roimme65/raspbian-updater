# Scripts Verzeichnis

Dieses Verzeichnis enthält Automatisierungs-Scripts für das Raspbian Auto-Updater Projekt.

## 📜 Verfügbare Scripts

### `create-release.sh`

Automatisiert den Release-Prozess für neue Versionen.

#### Verwendung

```bash
# Patch Release (1.0.6 → 1.0.7)
./scripts/create-release.sh patch

# Minor Release (1.0.6 → 1.1.0)
./scripts/create-release.sh minor

# Major Release (1.0.6 → 2.0.0)
./scripts/create-release.sh major

# Vollautomatisch ohne Editor
./scripts/create-release.sh patch --auto
```

#### Was das Script macht

1. ✅ Validiert Git-Status (sauber, auf main Branch)
2. ✅ Liest aktuelle Version aus `VERSION` Datei
3. ✅ Berechnet neue Version basierend auf Bump-Type
4. ✅ Aktualisiert `VERSION` Datei
5. ✅ Aktualisiert README.md Badge
6. ✅ Generiert Release-Notes aus Git-Commits
7. ✅ Aktualisiert `CHANGELOG.md`
8. ✅ Erstellt Git-Commit und Tag
9. ✅ Pusht zu GitHub (main + Tag)
10. ✅ Erstellt GitHub Release (falls `gh` CLI verfügbar)

#### Voraussetzungen

- Git Repository mit sauberem Status
- Auf `main` Branch
- Optional: `gh` CLI für automatische GitHub Release-Erstellung
  ```bash
  # GitHub CLI installieren (Debian/Ubuntu)
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
    sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh
  
  # Authentifizierung
  gh auth login
  ```

#### Release-Notes Generierung

Das Script analysiert Git-Commits und kategorisiert sie automatisch:

| Commit-Präfix | Kategorie | Beispiel |
|---------------|-----------|----------|
| `feat:`, `feature:`, `add:`, `✨` | 🎯 Neue Features | `feat: Add quick update mode` |
| `fix:`, `bug:`, `🐛` | 🐛 Bugfixes | `fix: Resolve cron timing issue` |
| `security:`, `sec:`, `🔒` | 🔒 Sicherheit | `security: Fix shell injection` |
| `improve:`, `refactor:`, `🔧` | 🔧 Verbesserungen | `improve: Better error handling` |

#### Manuelles Editieren

Wenn `--auto` nicht verwendet wird, öffnet das Script den Editor für Release-Notes:

```bash
./scripts/create-release.sh patch
# → Öffnet Editor mit generiertem Template
# → Nach Speichern und Schließen: Script erneut ausführen
./scripts/create-release.sh patch
# → Fährt mit Commit und Push fort
```

#### Beispiel-Workflow

```bash
# 1. Änderungen commiten
git add .
git commit -m "feat: Add desktop notification support"

# 2. Release erstellen
./scripts/create-release.sh minor

# 3. Bei Bedarf Release-Notes anpassen
nano releases/v1.1.0.md

# 4. Release finalisieren
./scripts/create-release.sh minor
```

## 🔄 GitHub Actions Integration

Das Release-Script arbeitet Hand-in-Hand mit GitHub Actions:

### Automatischer Workflow

1. **Lokaler Release:** `./scripts/create-release.sh patch`
2. **Git Push:** Script pusht Tag zu GitHub
3. **GitHub Actions:** Erkennt Tag und startet `.github/workflows/release.yml`
4. **Validierung:** Prüft VERSION und Release-Notes
5. **GitHub Release:** Erstellt Release mit Artefakten

### Manuelle Trigger

Falls das Script kein GitHub Release erstellen konnte:

```bash
# Manuell mit gh CLI
gh release create v1.0.7 \
  --title "v1.0.7 - Raspbian Auto-Updater" \
  --notes-file releases/v1.0.7.md \
  raspbian_autoupdater.py \
  install.sh \
  uninstall.sh \
  manage_cronjobs.sh
```

## 🛠️ Entwicklung

### Neue Scripts hinzufügen

1. Script in `scripts/` Verzeichnis erstellen
2. Ausführbar machen: `chmod +x scripts/new-script.sh`
3. Dokumentation in dieser README hinzufügen
4. In `.gitignore` ergänzen falls Temp-Dateien entstehen

### Best Practices

- ✅ Verwende `set -e` am Anfang (Exit bei Fehler)
- ✅ Farbige Ausgabe für bessere Lesbarkeit
- ✅ Validierung von Inputs und Voraussetzungen
- ✅ Hilfetext bei falscher Verwendung
- ✅ Cleanup von temporären Dateien

## 📚 Weiterführende Informationen

- [GitHub CLI Dokumentation](https://cli.github.com/manual/)
- [Semantic Versioning](https://semver.org/lang/de/)
- [Keep a Changelog](https://keepachangelog.com/de/1.0.0/)
- [Git Tagging](https://git-scm.com/book/de/v2/Git-Grundlagen-Taggen)

## 🐛 Troubleshooting

### "Git-Arbeitsverzeichnis nicht sauber"
```bash
# Prüfe Status
git status

# Committe oder stash Änderungen
git add .
git commit -m "Prepare for release"
# oder
git stash
```

### "Nicht auf main Branch"
```bash
# Wechsle zu main
git checkout main

# Hole neueste Änderungen
git pull origin main
```

### "gh CLI nicht installiert"
```bash
# Release wird trotzdem erstellt, aber nicht auf GitHub
# Entweder gh CLI installieren oder manuell auf GitHub erstellen
```

### "VERSION file missing"
```bash
# Script erstellt automatisch VERSION mit 1.0.6
# Oder manuell erstellen
echo "1.0.6" > VERSION
```

---

**Hinweis:** Dieses Verzeichnis ist für Maintainer und Contributors gedacht. Normale Benutzer benötigen diese Scripts nicht für die Verwendung des Auto-Updaters.
