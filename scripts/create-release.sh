#!/bin/bash
#
# Raspbian Auto-Updater - Automatische Release-Erstellung
#
# Verwendung: ./scripts/create-release.sh [major|minor|patch] [--auto]
#
# Beispiel: ./scripts/create-release.sh patch
#   → Bumpt 1.0.6 zu 1.0.7 (mit Editor)
# Beispiel: ./scripts/create-release.sh patch --auto
#   → Vollautomatisch ohne Editor
#

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funktionen
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse Argumente
BUMP_TYPE="patch"
AUTO_MODE=false

for arg in "$@"; do
    case $arg in
        --auto)
            AUTO_MODE=true
            ;;
        major|minor|patch)
            BUMP_TYPE=$arg
            ;;
        *)
            print_error "Ungültiges Argument: $arg"
            echo "Verwendung: $0 [major|minor|patch] [--auto]"
            exit 1
            ;;
    esac
done

# Prüfe ob im richtigen Verzeichnis
if [ ! -f "raspbian_autoupdater.py" ] || [ ! -f "install.sh" ]; then
    print_error "Bitte aus dem Repository-Root ausführen"
    exit 1
fi

# Prüfe ob git sauber ist
if [ -n "$(git status --porcelain)" ]; then
    print_error "Git-Arbeitsverzeichnis nicht sauber. Bitte committe alle Änderungen."
    git status --short
    exit 1
fi

# Prüfe ob auf main Branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    print_error "Nicht auf main Branch. Aktuell auf: $CURRENT_BRANCH"
    exit 1
fi

# Hole aktuelle Version aus VERSION Datei (oder erstelle sie)
if [ ! -f "VERSION" ]; then
    echo "1.0.6" > VERSION
    print_warning "VERSION Datei erstellt mit 1.0.6"
fi

CURRENT_VERSION=$(cat VERSION)
print_info "Aktuelle Version: v$CURRENT_VERSION"

# Parse Version
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Bestimme neue Version
case $BUMP_TYPE in
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_MINOR=0
        NEW_PATCH=0
        ;;
    minor)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$((MINOR + 1))
        NEW_PATCH=0
        ;;
    patch)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$MINOR
        NEW_PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}"
print_info "Neue Version: v$NEW_VERSION (${BUMP_TYPE} bump)"

# Frage Nutzer um Bestätigung (außer im Auto-Mode)
if [ "$AUTO_MODE" = false ]; then
    read -p "$(echo -e ${YELLOW}Möchtest du mit dem Release v$NEW_VERSION fortfahren? [y/N] ${NC})" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Release abgebrochen"
        exit 0
    fi
else
    print_info "Auto-Mode: Fahre automatisch fort mit v$NEW_VERSION"
fi

# Schritt 1: Version aktualisieren
print_info "Aktualisiere VERSION Datei..."
echo "$NEW_VERSION" > VERSION
print_success "Version aktualisiert: v$NEW_VERSION"

# Schritt 2: Version im README.md Badge aktualisieren
print_info "Aktualisiere README.md Badge..."
if [ -f "README.md" ]; then
    sed -i "s/version-[0-9]*\.[0-9]*\.[0-9]*/version-${NEW_VERSION}/g" README.md
    print_success "README.md Badge aktualisiert"
fi

# Schritt 3: Release-Notes erstellen
RELEASE_NOTES_FILE="releases/v${NEW_VERSION}.md"

# Funktion: Generiere automatische Release-Notes aus Git-Commits
generate_auto_release_notes() {
    local prev_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    local new_version="v${NEW_VERSION}"
    
    print_info "Analysiere Commits seit letztem Release..."
    
    # Hole Commits seit letztem Tag
    local commits
    if [ -n "$prev_tag" ]; then
        commits=$(git log ${prev_tag}..HEAD --pretty=format:"%s" 2>/dev/null || echo "")
    else
        commits=$(git log --pretty=format:"%s" 2>/dev/null || echo "")
    fi
    
    # Kategorisiere Commits
    local features=""
    local improvements=""
    local bugfixes=""
    local security=""
    local other=""
    
    while IFS= read -r commit; do
        [[ -z "$commit" ]] && continue
        
        if [[ "$commit" =~ ^(feat|feature|add|✨) ]] || [[ "$commit" =~ [Nn]ew[[:space:]][Ff]eature ]]; then
            features="${features}- ${commit}\n"
        elif [[ "$commit" =~ ^(fix|bug|🐛) ]]; then
            bugfixes="${bugfixes}- ${commit}\n"
        elif [[ "$commit" =~ ^(security|sec|🔒|🔐) ]]; then
            security="${security}- ${commit}\n"
        elif [[ "$commit" =~ ^(improve|enhance|update|refactor|🔧|⚡|docs|📝) ]]; then
            improvements="${improvements}- ${commit}\n"
        else
            other="${other}- ${commit}\n"
        fi
    done <<< "$commits"
    
    # Wenn keine kategorisierten Commits, nutze "other"
    if [[ -z "$features" && -z "$bugfixes" && -z "$improvements" && -z "$security" ]]; then
        improvements="$other"
    fi
    
    # Default Werte wenn leer
    [[ -z "$features" ]] && features="- Keine neuen Features in diesem Release\n"
    [[ -z "$improvements" ]] && improvements="- Code-Qualität und Dokumentation verbessert\n"
    [[ -z "$bugfixes" ]] && bugfixes="- Keine Bugfixes in diesem Release\n"
    [[ -z "$security" ]] && security="- Keine Sicherheitsupdates in diesem Release\n"
    
    # Erstelle Release-Notes
    cat > "$RELEASE_NOTES_FILE" << EOF
# Release v${NEW_VERSION}

**Veröffentlicht:** $(date +"%-d. %B %Y" 2>/dev/null || date +"%d. %B %Y")

## 📦 Übersicht

Raspbian Trixie Auto-Updater v${NEW_VERSION} - Automatisches Update-System für Raspbian/Debian Trixie mit detaillierter Statusanzeige und Desktop-Benachrichtigungen.

## 🎯 Neue Features

$(echo -e "$features")

## 🔧 Verbesserungen

$(echo -e "$improvements")

## 🐛 Bugfixes

$(echo -e "$bugfixes")

## 🔒 Sicherheit

$(echo -e "$security")

## 🚀 Installation

### Schnellinstallation

\`\`\`bash
# Repository klonen
git clone https://github.com/roimme65/raspbian-updater.git
cd raspbian-updater

# Installation mit automatischer Einrichtung
sudo ./install.sh
\`\`\`

### Verwendung

\`\`\`bash
# Vollständiges Update
sudo raspbian-autoupdater

# Schnelles Update (ohne dist-upgrade)
sudo raspbian-autoupdater --quick

# Test-Modus (Dry-Run)
raspbian-autoupdater --dry-run
\`\`\`

## 📋 Features

- ✅ Vollautomatische System-Updates
- 🎨 Echtzeit-Statusanzeige mit Farbcodierung
- 📝 Detailliertes Logging (Text + JSON)
- 🔔 Desktop-Benachrichtigungen
- 📅 Cronjob-Verwaltung
- 🔒 Root-Rechte-Prüfung
- 🛡️ Saubere Fehlerbehandlung

## 📋 Systemanforderungen

- **OS:** Raspbian/Debian Trixie (oder höher)
- **Python:** 3.9 oder höher
- **Root-Rechte:** Erforderlich für System-Updates
- **Optional:** libnotify-bin für Desktop-Benachrichtigungen

## 🔗 Links

- [README](https://github.com/roimme65/raspbian-updater/blob/main/README.md)
- [CHANGELOG](https://github.com/roimme65/raspbian-updater/blob/main/CHANGELOG.md)
- [SECURITY](https://github.com/roimme65/raspbian-updater/blob/main/SECURITY.md)
- [GitHub Release](https://github.com/roimme65/raspbian-updater/releases/tag/v${NEW_VERSION})

---

**Vielen Dank fürs Verwenden! 🙏**

Für Fragen oder Probleme öffne bitte ein [Issue auf GitHub](https://github.com/roimme65/raspbian-updater/issues).
EOF
}

if [ -f "$RELEASE_NOTES_FILE" ]; then
    print_warning "Release-Notes existieren bereits: $RELEASE_NOTES_FILE"
else
    if [ "$AUTO_MODE" = true ]; then
        generate_auto_release_notes
        print_success "Release-Notes automatisch generiert"
    else
        print_info "Erstelle Release-Notes Template..."
        generate_auto_release_notes
        print_success "Release-Notes Template erstellt: $RELEASE_NOTES_FILE"
        print_warning "Bitte bearbeite die Release-Notes und führe das Skript dann erneut aus"
        
        # Öffne Editor
        if command -v ${EDITOR:-nano} &> /dev/null; then
            ${EDITOR:-nano} "$RELEASE_NOTES_FILE"
        fi
        
        print_info "Nach dem Bearbeiten führe das Skript erneut aus:"
        echo "  ./scripts/create-release.sh $BUMP_TYPE"
        exit 0
    fi
fi

# Schritt 4: CHANGELOG.md aktualisieren (oder erstellen)
print_info "Aktualisiere CHANGELOG.md..."

if [ ! -f "CHANGELOG.md" ]; then
    cat > CHANGELOG.md << 'EOFHEAD'
# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

---

EOFHEAD
fi

# Temporäre Datei mit neuem Eintrag
{
    head -n 7 CHANGELOG.md
    cat << EOFCHG

## [${NEW_VERSION}] - $(date +"%Y-%m-%d")

### Siehe
- Detaillierte Release-Notes: [releases/v${NEW_VERSION}.md](releases/v${NEW_VERSION}.md)

---
EOFCHG
    tail -n +8 CHANGELOG.md
} > CHANGELOG.md.new
mv CHANGELOG.md.new CHANGELOG.md

print_success "CHANGELOG.md aktualisiert"

# Schritt 5: Git commit
print_info "Erstelle Git-Commit..."
git add VERSION "$RELEASE_NOTES_FILE" CHANGELOG.md README.md
git commit -m "Release v${NEW_VERSION}

- Bump version to v${NEW_VERSION}
- Add release notes
- Update CHANGELOG and README badge"
print_success "Commit erstellt"

# Schritt 6: Git Tag erstellen
print_info "Erstelle Git-Tag v${NEW_VERSION}..."
git tag -a "v${NEW_VERSION}" -m "Release ${NEW_VERSION}"
print_success "Tag erstellt: v${NEW_VERSION}"

# Schritt 7: Push zu GitHub
print_info "Pushe zu GitHub..."
git push origin main
git push origin "v${NEW_VERSION}"
print_success "Gepusht zu GitHub"

# Schritt 8: Erstelle GitHub Release
print_info "Erstelle GitHub Release..."

# Warte kurz, damit GitHub den Tag registriert
sleep 2

# Erstelle Release mit gh CLI
if command -v gh &> /dev/null; then
    if gh release create "v${NEW_VERSION}" \
        --title "v${NEW_VERSION} - Raspbian Auto-Updater" \
        --notes-file "$RELEASE_NOTES_FILE" \
        raspbian_autoupdater.py \
        install.sh \
        uninstall.sh \
        manage_cronjobs.sh; then
        print_success "GitHub Release erstellt: https://github.com/roimme65/raspbian-updater/releases/tag/v${NEW_VERSION}"
    else
        print_warning "GitHub Release konnte nicht erstellt werden. Prüfe gh CLI Authentifizierung."
    fi
else
    print_warning "gh CLI nicht installiert. Release manuell auf GitHub erstellen."
    print_info "Oder installiere gh CLI: https://cli.github.com/"
fi

# Fertig!
echo ""
print_success "🎉 Release v${NEW_VERSION} wurde erfolgreich erstellt!"
echo ""
print_info "Das Release ist verfügbar unter:"
echo "  https://github.com/roimme65/raspbian-updater/releases/tag/v${NEW_VERSION}"
echo ""
