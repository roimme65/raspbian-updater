#!/usr/bin/env python3
"""
Raspbian Trixie Auto-Updater
Automatisiertes Update-System mit Statusanzeige für Raspbian/Debian Trixie

Autor: Auto-generiert
Datum: 2025-10-24
"""

import subprocess
import sys
import os
import time
from datetime import datetime
from enum import Enum
from typing import Optional, Tuple
import json


class UpdateStatus(Enum):
    """Status-Codes für Update-Prozesse"""
    PENDING = "ausstehend"
    RUNNING = "läuft"
    SUCCESS = "erfolgreich"
    FAILED = "fehlgeschlagen"
    SKIPPED = "übersprungen"


class Color:
    """ANSI-Farbcodes für Terminal-Ausgabe"""
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


class RaspbianAutoUpdater:
    """Hauptklasse für automatische Raspbian-Updates"""
    
    def __init__(self, log_dir: str = "/var/log/raspbian-updater", dry_run: bool = False):
        """
        Initialisiert den Auto-Updater
        
        Args:
            log_dir: Verzeichnis für Log-Dateien
            dry_run: Wenn True, werden nur Informationen angezeigt ohne Updates durchzuführen
        """
        self.log_dir = log_dir
        self.dry_run = dry_run
        self.start_time = datetime.now()
        self.log_file = None
        self.status_log = {
            "start_time": self.start_time.isoformat(),
            "steps": []
        }
        self.updated_packages = []
        self.upgraded_packages = []
        
        # Log-Verzeichnis erstellen
        if not dry_run:
            os.makedirs(log_dir, exist_ok=True)
            timestamp = self.start_time.strftime("%Y%m%d_%H%M%S")
            self.log_file = os.path.join(log_dir, f"update_{timestamp}.log")
    
    def print_status(self, message: str, status: UpdateStatus = None, color: str = Color.OKBLUE):
        """
        Gibt eine formatierte Statusmeldung aus
        
        Args:
            message: Die anzuzeigende Nachricht
            status: Optional - Update-Status
            color: ANSI-Farbcode
        """
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        status_text = f"[{status.value.upper()}]" if status else ""
        
        output = f"{color}{timestamp} {status_text} {message}{Color.ENDC}"
        print(output)
        
        # In Log-Datei schreiben
        if self.log_file:
            with open(self.log_file, 'a') as f:
                f.write(f"{timestamp} {status_text} {message}\n")
    
    def print_header(self, title: str):
        """Gibt eine formatierte Überschrift aus"""
        separator = "=" * 70
        print(f"\n{Color.HEADER}{Color.BOLD}{separator}")
        print(f"{title.center(70)}")
        print(f"{separator}{Color.ENDC}\n")
    
    def check_root(self) -> bool:
        """
        Prüft, ob das Skript mit Root-Rechten ausgeführt wird
        
        Returns:
            True wenn Root-Rechte vorhanden, sonst False
        """
        if os.geteuid() != 0:
            self.print_status(
                "Dieses Skript benötigt Root-Rechte. Bitte mit 'sudo' ausführen.",
                UpdateStatus.FAILED,
                Color.FAIL
            )
            return False
        return True
    
    def run_command(
        self, 
        command: list, 
        step_name: str, 
        show_output: bool = True
    ) -> Tuple[bool, Optional[str]]:
        """
        Führt einen Befehl aus und zeigt den Status an
        
        Args:
            command: Der auszuführende Befehl als Liste
            step_name: Name des Schritts für die Statusanzeige
            show_output: Ob die Ausgabe in Echtzeit angezeigt werden soll
            
        Returns:
            Tuple (Erfolg, Ausgabe)
        """
        step_start_time = datetime.now()
        self.print_status(f"Starte: {step_name}", UpdateStatus.RUNNING, Color.OKCYAN)
        
        step_log = {
            "step": step_name,
            "command": " ".join(command),
            "start_time": step_start_time.isoformat(),
            "status": UpdateStatus.RUNNING.value
        }
        
        if self.dry_run:
            self.print_status(
                f"DRY-RUN: Würde ausführen: {' '.join(command)}", 
                UpdateStatus.SKIPPED, 
                Color.WARNING
            )
            step_log["status"] = UpdateStatus.SKIPPED.value
            step_log["end_time"] = datetime.now().isoformat()
            self.status_log["steps"].append(step_log)
            return True, None
        
        try:
            if show_output:
                # Zeige Ausgabe in Echtzeit
                process = subprocess.Popen(
                    command,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    universal_newlines=True,
                    bufsize=1
                )
                
                output_lines = []
                for line in process.stdout:
                    print(f"  {line.rstrip()}")
                    output_lines.append(line)
                    if self.log_file:
                        with open(self.log_file, 'a') as f:
                            f.write(f"  {line}")
                
                process.wait()
                output = "".join(output_lines)
                returncode = process.returncode
            else:
                # Führe Befehl ohne Ausgabe aus
                result = subprocess.run(
                    command,
                    capture_output=True,
                    text=True,
                    check=False
                )
                output = result.stdout + result.stderr
                returncode = result.returncode
            
            step_end_time = datetime.now()
            duration = (step_end_time - step_start_time).total_seconds()
            
            if returncode == 0:
                self.print_status(
                    f"Abgeschlossen: {step_name} (Dauer: {duration:.2f}s)",
                    UpdateStatus.SUCCESS,
                    Color.OKGREEN
                )
                step_log["status"] = UpdateStatus.SUCCESS.value
                step_log["duration_seconds"] = duration
                step_log["end_time"] = step_end_time.isoformat()
                self.status_log["steps"].append(step_log)
                return True, output
            else:
                self.print_status(
                    f"Fehler bei: {step_name} (Exit-Code: {returncode})",
                    UpdateStatus.FAILED,
                    Color.FAIL
                )
                step_log["status"] = UpdateStatus.FAILED.value
                step_log["error_code"] = returncode
                step_log["error_output"] = output[-500:] if output else None
                step_log["end_time"] = step_end_time.isoformat()
                self.status_log["steps"].append(step_log)
                return False, output
                
        except Exception as e:
            self.print_status(
                f"Exception bei {step_name}: {str(e)}",
                UpdateStatus.FAILED,
                Color.FAIL
            )
            step_log["status"] = UpdateStatus.FAILED.value
            step_log["exception"] = str(e)
            step_log["end_time"] = datetime.now().isoformat()
            self.status_log["steps"].append(step_log)
            return False, None
    
    def parse_package_list(self, output: str) -> list:
        """
        Extrahiert Paketnamen aus der apt-Ausgabe
        
        Args:
            output: Die Ausgabe von apt-get
            
        Returns:
            Liste der Paketnamen mit Versionen
        """
        packages = []
        if not output:
            return packages
        
        lines = output.split('\n')
        in_upgrade_section = False
        
        for line in lines:
            # Erkenne "Die folgenden Pakete werden aktualisiert" Sektion
            if 'Die folgenden Pakete werden aktualisiert' in line or 'The following packages will be upgraded' in line:
                in_upgrade_section = True
                continue
            
            # Ende der Upgrade-Sektion
            if in_upgrade_section and ('aktualisiert,' in line or 'upgraded,' in line):
                in_upgrade_section = False
                continue
            
            # Sammle Pakete aus der Upgrade-Sektion
            if in_upgrade_section:
                # Pakete sind durch Leerzeichen getrennt
                pkg_line = line.strip()
                if pkg_line and not pkg_line.startswith('#'):
                    # Entferne führende/nachfolgende Leerzeichen und split
                    pkg_names = pkg_line.split()
                    packages.extend(pkg_names)
            
            # Alternative: Parse "Entpacken" Zeilen für Versionen
            if 'Entpacken von' in line or 'Unpacking' in line:
                # Format: "Entpacken von paket:arch (neue-version) über (alte-version) ..."
                try:
                    if '(' in line and ')' in line:
                        # Extrahiere Paketnamen
                        parts = line.split()
                        for i, part in enumerate(parts):
                            if part == 'von' or part == 'of':
                                if i + 1 < len(parts):
                                    pkg_with_arch = parts[i + 1]
                                    # Entferne :arch Suffix
                                    pkg_name = pkg_with_arch.split(':')[0]
                                    
                                    # Extrahiere Versionen
                                    version_match = line[line.find('('):]
                                    if 'über' in version_match or 'over' in version_match:
                                        # Format: (neue) über (alte)
                                        new_start = version_match.find('(') + 1
                                        new_end = version_match.find(')')
                                        new_ver = version_match[new_start:new_end]
                                        
                                        rest = version_match[new_end+1:]
                                        if '(' in rest and ')' in rest:
                                            old_start = rest.find('(') + 1
                                            old_end = rest.find(')')
                                            old_ver = rest[old_start:old_end]
                                            
                                            version_info = f"{pkg_name} {old_ver} → {new_ver}"
                                            # Nur hinzufügen wenn noch nicht vorhanden
                                            if not any(pkg_name in p for p in packages):
                                                packages.append(version_info)
                                            else:
                                                # Ersetze einfachen Namen mit Version
                                                packages = [version_info if p == pkg_name else p for p in packages]
                                    break
                except:
                    pass
        
        # Entferne Duplikate und leere Einträge
        packages = list(dict.fromkeys([p for p in packages if p]))
        
        return packages
    
    def apt_update(self) -> bool:
        """
        Führt 'apt update' aus
        
        Returns:
            True bei Erfolg, sonst False
        """
        return self.run_command(
            ["apt-get", "update", "-q"],
            "APT Update - Paketlisten aktualisieren",
            show_output=True
        )[0]
    
    def apt_upgrade(self) -> bool:
        """
        Führt 'apt upgrade' aus
        
        Returns:
            True bei Erfolg, sonst False
        """
        success, output = self.run_command(
            ["apt-get", "upgrade", "-y", "-q"],
            "APT Upgrade - Pakete aktualisieren",
            show_output=True
        )
        
        # Extrahiere aktualisierte Pakete
        if output:
            self.upgraded_packages.extend(self.parse_package_list(output))
        
        return success
    
    def apt_dist_upgrade(self) -> bool:
        """
        Führt 'apt dist-upgrade' aus
        
        Returns:
            True bei Erfolg, sonst False
        """
        success, output = self.run_command(
            ["apt-get", "dist-upgrade", "-y", "-q"],
            "APT Dist-Upgrade - Distribution aktualisieren",
            show_output=True
        )
        
        # Extrahiere aktualisierte Pakete
        if output:
            dist_packages = self.parse_package_list(output)
            # Füge nur Pakete hinzu, die noch nicht in der Liste sind
            for pkg in dist_packages:
                pkg_name = pkg.split()[0]
                if not any(pkg_name in existing for existing in self.upgraded_packages):
                    self.upgraded_packages.append(pkg)
        
        return success
    
    def apt_autoremove(self) -> bool:
        """
        Führt 'apt autoremove' aus
        
        Returns:
            True bei Erfolg, sonst False
        """
        return self.run_command(
            ["apt-get", "autoremove", "-y", "-q"],
            "APT Autoremove - Unnötige Pakete entfernen",
            show_output=True
        )[0]
    
    def apt_autoclean(self) -> bool:
        """
        Führt 'apt autoclean' aus
        
        Returns:
            True bei Erfolg, sonst False
        """
        return self.run_command(
            ["apt-get", "autoclean", "-q"],
            "APT Autoclean - Cache bereinigen",
            show_output=True
        )[0]
    
    def check_reboot_required(self) -> bool:
        """
        Prüft, ob ein Neustart erforderlich ist
        
        Returns:
            True wenn Neustart erforderlich, sonst False
        """
        reboot_required_file = "/var/run/reboot-required"
        return os.path.exists(reboot_required_file)
    
    def save_status_log(self):
        """Speichert den Status-Log als JSON"""
        if self.dry_run:
            return
        
        self.status_log["end_time"] = datetime.now().isoformat()
        self.status_log["duration_seconds"] = (
            datetime.now() - self.start_time
        ).total_seconds()
        self.status_log["upgraded_packages"] = self.upgraded_packages
        self.status_log["package_count"] = len(self.upgraded_packages)
        
        timestamp = self.start_time.strftime("%Y%m%d_%H%M%S")
        json_file = os.path.join(self.log_dir, f"update_status_{timestamp}.json")
        
        with open(json_file, 'w') as f:
            json.dump(self.status_log, f, indent=2, ensure_ascii=False)
        
        self.print_status(f"Status-Log gespeichert: {json_file}", color=Color.OKBLUE)
    
    def run_full_update(self) -> bool:
        """
        Führt einen vollständigen Update-Zyklus durch
        
        Returns:
            True wenn alle Schritte erfolgreich, sonst False
        """
        self.print_header("Raspbian Trixie Auto-Updater")
        
        if not self.check_root() and not self.dry_run:
            return False
        
        if self.dry_run:
            self.print_status("DRY-RUN Modus aktiviert", color=Color.WARNING)
        
        # Schritt 1: Update
        if not self.apt_update():
            self.print_status("Update fehlgeschlagen. Abbruch.", UpdateStatus.FAILED, Color.FAIL)
            self.save_status_log()
            return False
        
        # Schritt 2: Upgrade
        if not self.apt_upgrade():
            self.print_status("Upgrade fehlgeschlagen.", UpdateStatus.FAILED, Color.FAIL)
            # Trotzdem weitermachen mit Cleanup
        
        # Schritt 3: Dist-Upgrade
        if not self.apt_dist_upgrade():
            self.print_status("Dist-Upgrade fehlgeschlagen.", UpdateStatus.FAILED, Color.FAIL)
        
        # Schritt 4: Autoremove
        if not self.apt_autoremove():
            self.print_status("Autoremove fehlgeschlagen.", UpdateStatus.FAILED, Color.FAIL)
        
        # Schritt 5: Autoclean
        if not self.apt_autoclean():
            self.print_status("Autoclean fehlgeschlagen.", UpdateStatus.FAILED, Color.FAIL)
        
        # Status-Log speichern
        self.save_status_log()
        
        # Zusammenfassung
        self.print_header("Update-Zusammenfassung")
        
        total_duration = (datetime.now() - self.start_time).total_seconds()
        self.print_status(
            f"Gesamtdauer: {total_duration:.2f} Sekunden ({total_duration/60:.2f} Minuten)",
            color=Color.OKGREEN
        )
        
        # Zeige aktualisierte Pakete
        if self.upgraded_packages:
            self.print_status(
                f"\n📦 Aktualisierte Pakete ({len(self.upgraded_packages)}):",
                color=Color.OKCYAN
            )
            for i, package in enumerate(self.upgraded_packages, 1):
                self.print_status(f"  {i:3d}. {package}", color=Color.OKBLUE)
        else:
            self.print_status(
                "✓ Keine Pakete wurden aktualisiert (System ist auf dem neuesten Stand)",
                color=Color.OKGREEN
            )
        
        # Prüfe ob Neustart erforderlich
        if self.check_reboot_required():
            self.print_status(
                "\n⚠️  NEUSTART ERFORDERLICH! Bitte System neu starten.",
                color=Color.WARNING
            )
        else:
            self.print_status(
                "\n✓ Kein Neustart erforderlich.",
                color=Color.OKGREEN
            )
        
        if self.log_file:
            self.print_status(f"Log-Datei: {self.log_file}", color=Color.OKBLUE)
        
        return True


def main():
    """Hauptfunktion"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Raspbian Trixie Auto-Updater mit Statusanzeige"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Zeigt nur an, was ausgeführt würde, ohne Änderungen vorzunehmen"
    )
    parser.add_argument(
        "--log-dir",
        default="/var/log/raspbian-updater",
        help="Verzeichnis für Log-Dateien (Standard: /var/log/raspbian-updater)"
    )
    parser.add_argument(
        "--quick",
        action="store_true",
        help="Schnelles Update (nur update + upgrade, kein dist-upgrade)"
    )
    
    args = parser.parse_args()
    
    updater = RaspbianAutoUpdater(log_dir=args.log_dir, dry_run=args.dry_run)
    
    try:
        if args.quick:
            # Schnelles Update
            updater.print_header("Schnelles Update")
            if not updater.check_root() and not args.dry_run:
                sys.exit(1)
            
            updater.apt_update()
            updater.apt_upgrade()
            updater.save_status_log()
        else:
            # Vollständiges Update
            success = updater.run_full_update()
            sys.exit(0 if success else 1)
    
    except KeyboardInterrupt:
        print(f"\n{Color.WARNING}Update durch Benutzer abgebrochen.{Color.ENDC}")
        updater.save_status_log()
        sys.exit(130)
    except Exception as e:
        print(f"\n{Color.FAIL}Unerwarteter Fehler: {str(e)}{Color.ENDC}")
        updater.save_status_log()
        sys.exit(1)


if __name__ == "__main__":
    main()
