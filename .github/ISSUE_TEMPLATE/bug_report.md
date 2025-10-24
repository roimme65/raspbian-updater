---
name: Bug report
about: Melden Sie einen Fehler um uns zu helfen den Auto-Updater zu verbessern
title: '[BUG] '
labels: bug
assignees: ''

---

## 🐛 Fehlerbeschreibung
Eine klare und präzise Beschreibung des Fehlers.

## 📋 Schritte zur Reproduktion
Schritte um das Verhalten zu reproduzieren:
1. Befehl ausgeführt: `sudo raspbian-autoupdater ...`
2. Aktion durchgeführt: '...'
3. Fehler aufgetreten bei: '...'

## ✅ Erwartetes Verhalten
Eine klare und präzise Beschreibung was Sie erwartet haben.

## ❌ Tatsächliches Verhalten
Was ist stattdessen passiert?

## 📊 Log-Ausgabe
Bitte fügen Sie relevante Log-Ausgaben hinzu:

```
Fügen Sie hier die Terminal-Ausgabe oder Log-Datei-Inhalte ein
```

## 💻 Systeminformationen
Bitte vervollständigen Sie die folgenden Informationen:
 - **OS**: [z.B. Raspbian Trixie, Debian 13]
 - **Python Version**: [Ausgabe von `python3 --version`]
 - **Auto-Updater Version**: [z.B. v1.0.1]
 - **Hardware**: [z.B. Raspberry Pi 5, Raspberry Pi 4]

## 📝 Verwendeter Befehl
Welchen Befehl haben Sie ausgeführt?
```bash
# Beispiel:
sudo raspbian-autoupdater
# oder
sudo raspbian-autoupdater --quick
# oder
raspbian-autoupdater --dry-run
```

## 📸 Screenshots
Falls zutreffend, fügen Sie Screenshots hinzu um das Problem zu erklären.

## 📁 Log-Dateien
Falls verfügbar, bitte relevante Log-Dateien aus `/var/log/raspbian-updater/` anhängen:
- [ ] `update_YYYYMMDD_HHMMSS.log`
- [ ] `update_status_YYYYMMDD_HHMMSS.json`

## 🔄 Cronjob-Ausführung
Falls der Fehler bei automatischer Ausführung auftritt:
- [ ] Fehler tritt bei manuellem Ausführen auf
- [ ] Fehler tritt nur bei Cronjob-Ausführung auf
- **Cronjob-Zeile**: `...`

## 🔍 Zusätzlicher Kontext
Fügen Sie hier weitere Informationen zum Problem hinzu:
- Tritt der Fehler konsistent auf oder nur gelegentlich?
- Gab es kürzliche Systemänderungen?
- Funktionierte es zuvor?
