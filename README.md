# Manage-IP – Netzwerk-Adressverwaltung mit Django

## 🇩🇪 Deutsch
**Verwaltung von IP-Adressbereichen und Geräten über ein simples Webinterface mit Django.**

**Manage IP** ist eine webbasierte Anwendung zur strukturierten Verwaltung von IP-Adressbereichen und einzelnen Netzwerkgeräten. Die Software basiert auf **Django (Python)** und einem schlichten **HTML/CSS-Frontend**. Sie eignet sich ideal für kleine bis mittlere Netzwerke, z. B. zur Dokumentation von Kamera-Netzwerken, Büro-Infrastruktur oder Testumgebungen.

### Funktionen
- Verwaltung mehrerer Adressbereiche (z. B. `192.168.1.0/24`) mit Beschreibung  
- Zu jedem Bereich: Erfassung beliebiger IP-Adressen, Gerätebezeichnungen und installierter Software  
- Löschen und Bearbeiten von Adressbereichen und Einzel-IP-Einträgen  
- Automatische Trennung der Datenansicht je Bereich  
- Schlichtes, intuitives Frontend  
- Verwaltung über integriertes Django Admin Interface möglich

### Technologien
- **Backend:** Django (Python 3)  
- **Frontend:** HTML, CSS 
- **Datenbank:** SQLite (standardmäßig, leicht anpassbar)

### Management
- Service starten: systemctl start manage-ip
- Service stoppen: systemctl stop manage-ip
- Logs anzeigen: journalctl -u manage-ip -f


## 🇬🇧 English
**Manage IP ranges and devices through a simple web interface built with Django.**  

**Manage IP** is a web-based application for structured management of IP address ranges and individual network devices. The software is built with **Django (Python)** and a minimal **HTML/CSS frontend**. It is ideal for small to medium-sized networks, such as camera systems, office infrastructure, or test environments.

### Features
- Manage multiple IP address ranges (e.g. `192.168.1.0/24`) with description  
- Add devices with IP, name, and installed software per range  
- Delete or edit address ranges and individual IP entries  
- Automatic separation of device views by range  
- Clean and intuitive frontend  
- Full management also available via Django admin interface

### Technologies
- **Backend:** Django (Python 3)  
- **Frontend:** HTML, CSS
- **Database:** SQLite (by default, easily configurable)

### Management
- Service start: systemctl start manage-ip
- Service stop: systemctl stop manage-ip
- Show Logs: journalctl -u manage-ip -f


## ▶️ Installation
```bash
cd /opt
git clone https://github.com/manage-ip.git
bash install.sh
