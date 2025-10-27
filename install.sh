#!/bin/bash
# Installation Script für Raspbian Auto-Updater

set -e

echo "========================================"
echo "Raspbian Auto-Updater - Installation"
echo "========================================"
echo ""

# Prüfe Root-Rechte
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  Bitte als Root ausführen (sudo ./install.sh)"
    exit 1
fi

# Prüfe Python 3
echo "🐍 Prüfe Python-Installation..."
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 nicht gefunden!"
    echo "   Bitte installieren: sudo apt-get install python3"
    exit 1
fi

# Prüfe Python Version (3.9+)
PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
REQUIRED_VERSION="3.9"
if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ Python $PYTHON_VERSION gefunden, aber $REQUIRED_VERSION+ erforderlich!"
    echo "   Aktuelle Version: $PYTHON_VERSION"
    echo "   Benötigte Version: $REQUIRED_VERSION oder höher"
    echo ""
    echo "   Auf Debian/Raspbian Bullseye oder älter:"
    echo "   sudo apt-get update"
    echo "   sudo apt-get install python3.9"
    exit 1
fi
echo "✓ Python $PYTHON_VERSION gefunden"

# Aktuelles Verzeichnis
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATER_SCRIPT="$SCRIPT_DIR/raspbian_autoupdater.py"

echo "📍 Installationsverzeichnis: $SCRIPT_DIR"

# Prüfe ob Skript existiert
if [ ! -f "$UPDATER_SCRIPT" ]; then
    echo "❌ Fehler: raspbian_autoupdater.py nicht gefunden!"
    exit 1
fi

# Mache Skript ausführbar
echo "🔧 Setze Ausführungsrechte..."
chmod +x "$UPDATER_SCRIPT"

# Installiere libnotify-bin für Desktop-Benachrichtigungen
echo "📦 Installiere Desktop-Benachrichtigungs-Tools..."
if ! dpkg -l | grep -q "^ii  libnotify-bin"; then
    apt-get update -qq
    apt-get install -y -qq libnotify-bin
    echo "✓ libnotify-bin installiert"
else
    echo "✓ libnotify-bin bereits installiert"
fi

# Installiere notification-daemon für Raspberry Pi Desktop
if ! dpkg -l | grep -q "^ii  notification-daemon"; then
    apt-get install -y -qq notification-daemon
    echo "✓ notification-daemon installiert"
else
    echo "✓ notification-daemon bereits installiert"
fi

# Richte notification-daemon Autostart ein für den aktuellen Benutzer
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    AUTOSTART_DIR="$USER_HOME/.config/autostart"
    AUTOSTART_FILE="$AUTOSTART_DIR/notification-daemon.desktop"
    
    echo "🔧 Richte notification-daemon Autostart ein..."
    
    # Erstelle Autostart-Verzeichnis
    sudo -u "$SUDO_USER" mkdir -p "$AUTOSTART_DIR"
    
    # Erstelle Autostart-Datei
    cat > "$AUTOSTART_FILE" << 'EOF'
[Desktop Entry]
Type=Application
Name=Notification Daemon
Comment=Display notifications for raspbian-autoupdater
Exec=/usr/lib/notification-daemon/notification-daemon
Terminal=false
Hidden=false
X-GNOME-Autostart-enabled=true
EOF
    
    # Setze korrekte Berechtigungen
    chown "$SUDO_USER:$SUDO_USER" "$AUTOSTART_FILE"
    chmod +x "$AUTOSTART_FILE"
    
    echo "✓ notification-daemon Autostart eingerichtet"
    
    # Starte notification-daemon sofort (im Hintergrund)
    if ! pgrep -x notification-daemon > /dev/null; then
        sudo -u "$SUDO_USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u "$SUDO_USER")/bus \
            /usr/lib/notification-daemon/notification-daemon &
        echo "✓ notification-daemon gestartet"
    fi
fi

echo "ℹ️  Hinweis: Desktop-Benachrichtigungen funktionieren nur in GUI-Sessions"
echo "   Falls Sie die grafische Oberfläche verwenden, werden Sie über Updates informiert."

# Erstelle Log-Verzeichnis
echo "📁 Erstelle Log-Verzeichnis..."
mkdir -p /var/log/raspbian-updater
chmod 755 /var/log/raspbian-updater

# Erstelle Symlink in /usr/local/bin
echo "🔗 Erstelle Symlink..."
ln -sf "$UPDATER_SCRIPT" /usr/local/bin/raspbian-autoupdater

# Teste das Skript
echo ""
echo "🧪 Teste Installation (Dry-Run)..."
"$UPDATER_SCRIPT" --dry-run

echo ""
echo "✅ Installation erfolgreich!"
echo ""
echo "Verwendung:"
echo "  sudo raspbian-autoupdater              # Vollständiges Update"
echo "  sudo raspbian-autoupdater --quick      # Schnelles Update"
echo "  raspbian-autoupdater --dry-run         # Test-Modus"
echo ""
echo "Logs werden gespeichert in: /var/log/raspbian-updater/"
echo ""

# Frage nach Cron-Job Installation
read -p "Möchten Sie einen automatischen Cron-Job einrichten? (j/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Jj]$ ]]; then
    echo ""
    echo "Wählen Sie die Häufigkeit:"
    echo "1) Täglich um 3:00 Uhr"
    echo "2) Sonntags um 2:00 Uhr"
    echo "3) Täglich um 3:00 Uhr (vollständig) + 6:00 Uhr (schnell)"
    echo "4) Benutzerdefiniert"
    read -p "Auswahl (1-4): " -n 1 -r CRON_CHOICE
    echo
    
    CRON_LINE=""
    case $CRON_CHOICE in
        1)
            CRON_LINE="0 3 * * * /usr/local/bin/raspbian-autoupdater"
            ;;
        2)
            CRON_LINE="0 2 * * 0 /usr/local/bin/raspbian-autoupdater"
            ;;
        3)
            # Zwei separate Zeilen für vollständig + schnell
            TEMP_CRON="/tmp/raspbian_cron_$$"
            crontab -l 2>/dev/null | grep -v raspbian-autoupdater > "$TEMP_CRON" || true
            echo "0 3 * * * /usr/local/bin/raspbian-autoupdater" >> "$TEMP_CRON"
            echo "0 6 * * * /usr/local/bin/raspbian-autoupdater --quick" >> "$TEMP_CRON"
            
            if [ -s "$TEMP_CRON" ]; then
                crontab "$TEMP_CRON"
                CRON_RESULT=$?
            else
                echo "❌ Fehler: Temporäre Datei ist leer"
                CRON_RESULT=1
            fi
            
            rm -f "$TEMP_CRON"
            
            if [ $CRON_RESULT -eq 0 ]; then
                echo "✅ Cron-Jobs wurden eingerichtet!"
                echo ""
                echo "Aktuelle Cron-Jobs:"
                crontab -l | grep raspbian-autoupdater
            else
                echo "❌ Fehler beim Einrichten der Cron-Jobs"
            fi
            CRON_LINE=""  # Verhindere doppelte Ausführung unten
            ;;
        4)
            echo "Bitte Cron-Syntax eingeben (z.B. '0 3 * * *' für täglich um 3:00):"
            read -r CRON_TIME
            CRON_LINE="$CRON_TIME /usr/local/bin/raspbian-autoupdater"
            ;;
        *)
            echo "Ungültige Auswahl. Überspringe Cron-Installation."
            ;;
    esac
    
    if [ -n "$CRON_LINE" ]; then
        # Füge Cron-Job hinzu (entferne alte raspbian-autoupdater Einträge)
        # Verwende temporäres File um Pipe-Probleme zu vermeiden
        TEMP_CRON="/tmp/raspbian_cron_$$"
        crontab -l 2>/dev/null | grep -v raspbian-autoupdater > "$TEMP_CRON" || true
        echo "$CRON_LINE" >> "$TEMP_CRON"
        
        if [ -s "$TEMP_CRON" ]; then
            crontab "$TEMP_CRON"
            CRON_RESULT=$?
        else
            echo "❌ Fehler: Temporäre Datei ist leer"
            CRON_RESULT=1
        fi
        
        rm -f "$TEMP_CRON"
        
        if [ $CRON_RESULT -eq 0 ]; then
            echo "✅ Cron-Job wurde eingerichtet!"
            echo ""
            echo "Aktuelle Cron-Jobs:"
            crontab -l 2>/dev/null | grep raspbian-autoupdater
        else
            echo "❌ Fehler beim Einrichten des Cron-Jobs"
            echo "Bitte manuell einrichten:"
            echo "  sudo crontab -e"
            echo "Und hinzufügen:"
            echo "  $CRON_LINE"
        fi
    fi
fi

echo ""
echo "🎉 Installation abgeschlossen!"
