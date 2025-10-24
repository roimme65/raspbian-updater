#!/bin/bash
# Verwaltungs-Script für Raspbian Auto-Updater Cronjobs

set -e

# Farben für Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Funktionen
show_header() {
    echo -e "\n${CYAN}${BOLD}========================================"
    echo -e "$1"
    echo -e "========================================${NC}\n"
}

show_current_cronjobs() {
    show_header "Aktuelle Cronjobs für Auto-Updater"
    
    if sudo crontab -l 2>/dev/null | grep -q "raspbian-autoupdater"; then
        echo -e "${GREEN}✓ Gefundene Cronjobs:${NC}\n"
        sudo crontab -l 2>/dev/null | grep "raspbian-autoupdater" | while IFS= read -r line; do
            echo -e "  ${BLUE}→${NC} $line"
            
            # Parse Cron-Zeit
            cron_parts=($line)
            minute="${cron_parts[0]}"
            hour="${cron_parts[1]}"
            day="${cron_parts[2]}"
            month="${cron_parts[3]}"
            weekday="${cron_parts[4]}"
            
            # Interpretiere Cron-Syntax
            schedule=""
            if [ "$minute" = "0" ] && [ "$hour" != "*" ] && [ "$day" = "*" ] && [ "$month" = "*" ] && [ "$weekday" = "*" ]; then
                schedule="Täglich um ${hour}:00 Uhr"
            elif [ "$minute" = "0" ] && [ "$hour" != "*" ] && [ "$weekday" = "0" ]; then
                schedule="Jeden Sonntag um ${hour}:00 Uhr"
            elif [ "$minute" = "0" ] && [ "$hour" != "*" ] && [ "$weekday" = "1" ]; then
                schedule="Jeden Montag um ${hour}:00 Uhr"
            elif [ "$minute" = "0" ] && [ "$hour" != "*" ]; then
                schedule="Um ${hour}:00 Uhr (siehe Cron-Syntax für Details)"
            else
                schedule="Siehe Cron-Syntax: $minute $hour $day $month $weekday"
            fi
            
            echo -e "    ${YELLOW}Zeitplan:${NC} $schedule"
            
            # Prüfe ob --quick Flag verwendet wird
            if echo "$line" | grep -q "\-\-quick"; then
                echo -e "    ${YELLOW}Modus:${NC} Schnelles Update (nur update + upgrade)"
            else
                echo -e "    ${YELLOW}Modus:${NC} Vollständiges Update"
            fi
            echo ""
        done
    else
        echo -e "${YELLOW}⚠️  Keine Cronjobs für raspbian-autoupdater gefunden${NC}"
    fi
}

show_cron_explanation() {
    show_header "Cron-Syntax Erklärung"
    
    echo -e "${BOLD}Format:${NC} Minute Stunde Tag Monat Wochentag Befehl\n"
    echo -e "${CYAN}Beispiele:${NC}"
    echo -e "  ${GREEN}0 3 * * *${NC}     - Täglich um 3:00 Uhr"
    echo -e "  ${GREEN}0 2 * * 0${NC}     - Jeden Sonntag um 2:00 Uhr"
    echo -e "  ${GREEN}0 */6 * * *${NC}   - Alle 6 Stunden"
    echo -e "  ${GREEN}30 4 1 * *${NC}    - Am 1. Tag jeden Monats um 4:30 Uhr"
    echo -e "  ${GREEN}0 1 * * 1-5${NC}   - Montag bis Freitag um 1:00 Uhr\n"
    
    echo -e "${BOLD}Wochentage:${NC}"
    echo -e "  0 = Sonntag, 1 = Montag, 2 = Dienstag, ..., 6 = Samstag\n"
}

show_next_runs() {
    show_header "Nächste geplante Ausführungen"
    
    if ! command -v crontab &> /dev/null; then
        echo -e "${RED}✗ crontab nicht verfügbar${NC}"
        return
    fi
    
    if sudo crontab -l 2>/dev/null | grep -q "raspbian-autoupdater"; then
        echo -e "${BLUE}Basierend auf aktueller Zeit: $(date '+%Y-%m-%d %H:%M:%S')${NC}\n"
        
        # Verwende systemctl für nächste Timer-Ausführungen (falls systemd Timer verwendet wird)
        if systemctl list-timers raspbian-autoupdate.timer 2>/dev/null | grep -q "raspbian-autoupdate"; then
            echo -e "${GREEN}Systemd Timer Status:${NC}"
            systemctl list-timers raspbian-autoupdate.timer --no-pager
            echo ""
        fi
        
        echo -e "${YELLOW}Hinweis:${NC} Für genaue nächste Ausführungszeiten verwenden Sie:"
        echo -e "  ${CYAN}systemctl list-timers${NC} (falls systemd Timer verwendet wird)"
        echo -e "  oder prüfen Sie /var/log/syslog für vergangene Ausführungen"
    else
        echo -e "${YELLOW}⚠️  Keine Cronjobs gefunden${NC}"
    fi
}

show_logs() {
    show_header "Letzte Update-Logs"
    
    LOG_DIR="/var/log/raspbian-updater"
    
    if [ -d "$LOG_DIR" ]; then
        echo -e "${BLUE}Log-Verzeichnis: $LOG_DIR${NC}\n"
        
        # Zeige letzte 5 Log-Dateien
        echo -e "${GREEN}Letzte 5 Update-Logs:${NC}\n"
        ls -lt "$LOG_DIR"/update_*.log 2>/dev/null | head -5 | while read -r line; do
            filename=$(echo "$line" | awk '{print $NF}')
            filedate=$(echo "$line" | awk '{print $6, $7, $8}')
            filesize=$(echo "$line" | awk '{print $5}')
            echo -e "  ${CYAN}→${NC} $(basename "$filename") ${YELLOW}($filedate, $filesize Bytes)${NC}"
        done
        
        echo -e "\n${GREEN}Letzte 5 Status-Logs (JSON):${NC}\n"
        ls -lt "$LOG_DIR"/update_status_*.json 2>/dev/null | head -5 | while read -r line; do
            filename=$(echo "$line" | awk '{print $NF}')
            filedate=$(echo "$line" | awk '{print $6, $7, $8}')
            
            # Zeige Zusammenfassung aus JSON
            if [ -f "$filename" ]; then
                package_count=$(grep -o '"package_count": [0-9]*' "$filename" 2>/dev/null | grep -o '[0-9]*')
                duration=$(grep -o '"duration_seconds": [0-9.]*' "$filename" 2>/dev/null | grep -o '[0-9.]*')
                
                echo -e "  ${CYAN}→${NC} $(basename "$filename") ${YELLOW}($filedate)${NC}"
                if [ -n "$package_count" ]; then
                    echo -e "    Pakete aktualisiert: $package_count"
                fi
                if [ -n "$duration" ]; then
                    minutes=$(echo "scale=2; $duration / 60" | bc 2>/dev/null || echo "?")
                    echo -e "    Dauer: ${duration}s (~${minutes}min)"
                fi
            fi
        done
        
        # Zeige letzten Log-Inhalt
        latest_log=$(ls -t "$LOG_DIR"/update_*.log 2>/dev/null | head -1)
        if [ -n "$latest_log" ]; then
            echo -e "\n${BOLD}Letzte Zeilen aus neuestem Log:${NC}"
            echo -e "${YELLOW}─────────────────────────────────────────${NC}"
            tail -15 "$latest_log"
            echo -e "${YELLOW}─────────────────────────────────────────${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Log-Verzeichnis nicht gefunden: $LOG_DIR${NC}"
    fi
}

add_cronjob() {
    show_header "Neuen Cronjob hinzufügen"
    
    echo -e "${BOLD}Wählen Sie eine Vorlage:${NC}\n"
    echo -e "  ${GREEN}1)${NC} Täglich um 3:00 Uhr (vollständig)"
    echo -e "  ${GREEN}2)${NC} Sonntags um 2:00 Uhr (vollständig)"
    echo -e "  ${GREEN}3)${NC} Täglich um 6:00 Uhr (schnell)"
    echo -e "  ${GREEN}4)${NC} Zweimal täglich: 3:00 (vollständig) + 15:00 (schnell)"
    echo -e "  ${GREEN}5)${NC} Benutzerdefiniert"
    echo -e "  ${YELLOW}0)${NC} Abbrechen\n"
    
    read -p "Auswahl: " choice
    
    CRON_LINE=""
    case $choice in
        1)
            CRON_LINE="0 3 * * * /usr/local/bin/raspbian-autoupdater"
            ;;
        2)
            CRON_LINE="0 2 * * 0 /usr/local/bin/raspbian-autoupdater"
            ;;
        3)
            CRON_LINE="0 6 * * * /usr/local/bin/raspbian-autoupdater --quick"
            ;;
        4)
            CRON_LINE="0 3 * * * /usr/local/bin/raspbian-autoupdater
0 15 * * * /usr/local/bin/raspbian-autoupdater --quick"
            ;;
        5)
            echo -e "\n${BOLD}Geben Sie die Cron-Zeit ein (z.B. '0 3 * * *'):${NC}"
            read -p "Zeit: " cron_time
            echo -e "\n${BOLD}Vollständig (v) oder Schnell (s)?${NC}"
            read -p "Modus [v/s]: " mode
            
            if [ "$mode" = "s" ]; then
                CRON_LINE="$cron_time /usr/local/bin/raspbian-autoupdater --quick"
            else
                CRON_LINE="$cron_time /usr/local/bin/raspbian-autoupdater"
            fi
            ;;
        0)
            echo -e "\n${YELLOW}Abgebrochen${NC}"
            return
            ;;
        *)
            echo -e "\n${RED}✗ Ungültige Auswahl${NC}"
            return
            ;;
    esac
    
    if [ -n "$CRON_LINE" ]; then
        # Füge Cron-Job hinzu
        # Hole existierende Crontab (ignoriere Fehler wenn leer)
        EXISTING_CRONTAB=$(sudo crontab -l 2>/dev/null || true)
        
        # Entferne alte raspbian-autoupdater Einträge und füge neue hinzu
        if [ -n "$EXISTING_CRONTAB" ]; then
            (echo "$EXISTING_CRONTAB" | grep -v "raspbian-autoupdater"; echo "$CRON_LINE") | sudo crontab -
        else
            echo "$CRON_LINE" | sudo crontab -
        fi
        
        echo -e "\n${GREEN}✓ Cronjob wurde hinzugefügt!${NC}\n"
        show_current_cronjobs
    fi
}

remove_cronjobs() {
    show_header "Cronjobs entfernen"
    
    if ! sudo crontab -l 2>/dev/null | grep -q "raspbian-autoupdater"; then
        echo -e "${YELLOW}⚠️  Keine Cronjobs für raspbian-autoupdater gefunden${NC}"
        return
    fi
    
    echo -e "${YELLOW}Aktuelle Cronjobs:${NC}\n"
    sudo crontab -l 2>/dev/null | grep "raspbian-autoupdater" | nl -w2 -s'. '
    
    echo -e "\n${RED}${BOLD}Möchten Sie ALLE raspbian-autoupdater Cronjobs entfernen?${NC}"
    read -p "Bestätigen [j/N]: " confirm
    
    if [[ $confirm =~ ^[Jj]$ ]]; then
        sudo crontab -l 2>/dev/null | grep -v "raspbian-autoupdater" | sudo crontab -
        echo -e "\n${GREEN}✓ Alle Cronjobs wurden entfernt${NC}"
    else
        echo -e "\n${YELLOW}Abgebrochen${NC}"
    fi
}

test_updater() {
    show_header "Test-Ausführung (Dry-Run)"
    
    echo -e "${BLUE}Führe raspbian-autoupdater im Test-Modus aus...${NC}\n"
    /usr/local/bin/raspbian-autoupdater --dry-run 2>&1 || raspbian_autoupdater.py --dry-run 2>&1
}

# Hauptmenü
show_menu() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║    Raspbian Auto-Updater - Cronjob Verwaltung             ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${GREEN}1)${NC} Aktuelle Cronjobs anzeigen"
    echo -e "${GREEN}2)${NC} Nächste geplante Ausführungen"
    echo -e "${GREEN}3)${NC} Update-Logs anzeigen"
    echo -e "${GREEN}4)${NC} Neuen Cronjob hinzufügen"
    echo -e "${GREEN}5)${NC} Cronjobs entfernen"
    echo -e "${GREEN}6)${NC} Test-Ausführung (Dry-Run)"
    echo -e "${GREEN}7)${NC} Cron-Syntax Hilfe"
    echo -e "${YELLOW}0)${NC} Beenden"
    echo ""
}

# Prüfe Root-Rechte für bestimmte Operationen
check_root_if_needed() {
    if [ "$1" = "write" ] && [ "$EUID" -ne 0 ]; then
        echo -e "${RED}✗ Diese Operation benötigt Root-Rechte${NC}"
        echo -e "${YELLOW}Bitte führen Sie das Skript mit 'sudo' aus${NC}"
        return 1
    fi
    return 0
}

# Hauptprogramm
if [ "$1" = "--show" ] || [ "$1" = "-s" ]; then
    show_current_cronjobs
    exit 0
elif [ "$1" = "--logs" ] || [ "$1" = "-l" ]; then
    show_logs
    exit 0
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Raspbian Auto-Updater - Cronjob Verwaltung"
    echo ""
    echo "Verwendung:"
    echo "  $0              Interaktives Menü"
    echo "  $0 --show       Zeige aktuelle Cronjobs"
    echo "  $0 --logs       Zeige Update-Logs"
    echo "  $0 --help       Diese Hilfe"
    exit 0
fi

# Interaktives Menü
while true; do
    show_menu
    read -p "Auswahl: " choice
    
    case $choice in
        1)
            show_current_cronjobs
            read -p "Drücken Sie Enter zum Fortfahren..."
            ;;
        2)
            show_next_runs
            read -p "Drücken Sie Enter zum Fortfahren..."
            ;;
        3)
            show_logs
            read -p "Drücken Sie Enter zum Fortfahren..."
            ;;
        4)
            if check_root_if_needed "write"; then
                add_cronjob
            fi
            read -p "Drücken Sie Enter zum Fortfahren..."
            ;;
        5)
            if check_root_if_needed "write"; then
                remove_cronjobs
            fi
            read -p "Drücken Sie Enter zum Fortfahren..."
            ;;
        6)
            test_updater
            read -p "Drücken Sie Enter zum Fortfahren..."
            ;;
        7)
            show_cron_explanation
            read -p "Drücken Sie Enter zum Fortfahren..."
            ;;
        0)
            echo -e "\n${GREEN}Auf Wiedersehen!${NC}\n"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Ungültige Auswahl${NC}"
            sleep 1
            ;;
    esac
done
