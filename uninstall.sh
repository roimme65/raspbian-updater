#!/bin/bash

# Raspbian Auto-Updater - Deinstallationsskript
# Entfernt das Auto-Updater System vom System

set -e

# Farben für Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║   Raspbian Auto-Updater - Deinstallation            ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Root-Rechte prüfen
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}✗ Fehler: Dieses Skript muss als root ausgeführt werden${NC}"
    echo "Bitte führen Sie aus: sudo ./uninstall.sh"
    exit 1
fi

echo -e "${YELLOW}⚠️  WARNUNG: Dies wird den Raspbian Auto-Updater vollständig entfernen!${NC}"
echo ""
echo "Folgendes wird entfernt:"
echo "  - Symlink: /usr/local/bin/raspbian-autoupdater"
echo "  - Alle Cronjobs für raspbian-autoupdater"
echo ""
echo "Folgendes bleibt erhalten (optional zu löschen):"
echo "  - Log-Verzeichnis: /var/log/raspbian-updater/"
echo "  - Quellcode im aktuellen Verzeichnis"
echo ""

read -p "Möchten Sie fortfahren? (j/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[JjYy]$ ]]; then
    echo -e "${YELLOW}Deinstallation abgebrochen.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}=== Deinstallation gestartet ===${NC}"
echo ""

# 1. Symlink entfernen
echo -n "Entferne Symlink... "
if [ -L "/usr/local/bin/raspbian-autoupdater" ]; then
    rm -f /usr/local/bin/raspbian-autoupdater
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}(nicht gefunden)${NC}"
fi

# 2. Cronjobs entfernen (für root)
echo -n "Suche nach Cronjobs (root)... "
if crontab -l 2>/dev/null | grep -q "raspbian-autoupdater"; then
    # Entferne alle raspbian-autoupdater Einträge
    crontab -l 2>/dev/null | grep -v "raspbian-autoupdater" | crontab -
    echo -e "${GREEN}✓ Entfernt${NC}"
else
    echo -e "${YELLOW}(keine gefunden)${NC}"
fi

# 3. Cronjobs für andere Benutzer prüfen
echo "Prüfe Cronjobs anderer Benutzer..."
FOUND_USER_CRONS=false
for user in $(cut -f1 -d: /etc/passwd); do
    if crontab -u "$user" -l 2>/dev/null | grep -q "raspbian-autoupdater"; then
        echo -e "  ${YELLOW}! Cronjob gefunden für Benutzer: $user${NC}"
        FOUND_USER_CRONS=true
        read -p "    Cronjob für $user entfernen? (j/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[JjYy]$ ]]; then
            crontab -u "$user" -l 2>/dev/null | grep -v "raspbian-autoupdater" | crontab -u "$user" -
            echo -e "    ${GREEN}✓ Entfernt${NC}"
        fi
    fi
done

if [ "$FOUND_USER_CRONS" = false ]; then
    echo -e "  ${GREEN}✓ Keine gefunden${NC}"
fi

# 4. Systemd Timer prüfen (falls vorhanden)
echo -n "Prüfe Systemd Timer... "
if systemctl list-unit-files 2>/dev/null | grep -q "raspbian-autoupdater"; then
    echo -e "${YELLOW}Gefunden!${NC}"
    read -p "Systemd Timer deaktivieren? (j/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[JjYy]$ ]]; then
        systemctl stop raspbian-autoupdater.timer 2>/dev/null || true
        systemctl disable raspbian-autoupdater.timer 2>/dev/null || true
        rm -f /etc/systemd/system/raspbian-autoupdater.service
        rm -f /etc/systemd/system/raspbian-autoupdater.timer
        systemctl daemon-reload
        echo -e "${GREEN}✓ Entfernt${NC}"
    fi
else
    echo -e "${GREEN}✓ (nicht installiert)${NC}"
fi

# 5. Desktop-Benachrichtigungs-Pakete optional deinstallieren
echo ""
echo -e "${YELLOW}Desktop-Benachrichtigungs-Pakete (libnotify-bin, notification-daemon)${NC}"
echo "Diese Pakete wurden von install.sh installiert für Desktop-Benachrichtigungen."
echo -e "${YELLOW}⚠️  WARNUNG: Diese Pakete könnten auch von anderen Programmen verwendet werden!${NC}"
read -p "Möchten Sie diese Pakete deinstallieren? (j/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[JjYy]$ ]]; then
    echo "Deinstalliere Desktop-Benachrichtigungs-Pakete..."
    
    # Stoppe notification-daemon falls er läuft
    pkill -x notification-daemon 2>/dev/null || true
    
    # Entferne Autostart-Datei für alle Benutzer
    for user_home in /home/*; do
        if [ -d "$user_home" ]; then
            AUTOSTART_FILE="$user_home/.config/autostart/notification-daemon.desktop"
            if [ -f "$AUTOSTART_FILE" ]; then
                rm -f "$AUTOSTART_FILE"
                echo -e "  ${GREEN}✓ Autostart entfernt für $(basename $user_home)${NC}"
            fi
        fi
    done
    
    # Deinstalliere Pakete
    apt-get remove -y libnotify-bin notification-daemon 2>/dev/null || echo -e "${YELLOW}(Einige Pakete waren nicht installiert)${NC}"
    apt-get autoremove -y 2>/dev/null
    echo -e "${GREEN}✓ Pakete deinstalliert${NC}"
else
    echo -e "${BLUE}ℹ Desktop-Benachrichtigungs-Pakete bleiben installiert${NC}"
    
    # Trotzdem Autostart-Datei entfernen (wurde von raspbian-updater erstellt)
    echo -e "${BLUE}Entferne notification-daemon Autostart (von raspbian-updater)...${NC}"
    for user_home in /home/*; do
        if [ -d "$user_home" ]; then
            AUTOSTART_FILE="$user_home/.config/autostart/notification-daemon.desktop"
            if [ -f "$AUTOSTART_FILE" ]; then
                # Prüfe ob Datei "raspbian-autoupdater" im Comment enthält
                if grep -q "raspbian-autoupdater" "$AUTOSTART_FILE" 2>/dev/null; then
                    rm -f "$AUTOSTART_FILE"
                    echo -e "  ${GREEN}✓ Autostart entfernt für $(basename $user_home)${NC}"
                fi
            fi
        fi
    done
fi

# 6. Log-Verzeichnis optional löschen
echo ""
if [ -d "/var/log/raspbian-updater" ]; then
    LOG_SIZE=$(du -sh /var/log/raspbian-updater 2>/dev/null | cut -f1)
    echo -e "${YELLOW}Log-Verzeichnis gefunden: /var/log/raspbian-updater/ (${LOG_SIZE})${NC}"
    read -p "Möchten Sie die Logs löschen? (j/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[JjYy]$ ]]; then
        rm -rf /var/log/raspbian-updater
        echo -e "${GREEN}✓ Logs gelöscht${NC}"
    else
        echo -e "${BLUE}ℹ Logs bleiben erhalten in: /var/log/raspbian-updater/${NC}"
    fi
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Deinstallation erfolgreich abgeschlossen        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Der Quellcode in diesem Verzeichnis wurde NICHT gelöscht."
echo "Sie können ihn manuell mit 'rm -rf $(pwd)' entfernen."
echo ""
echo -e "${BLUE}Vielen Dank für die Nutzung von Raspbian Auto-Updater!${NC}"
