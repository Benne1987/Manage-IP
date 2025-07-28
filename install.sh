#!/bin/bash

# Manage IP - Vollständiges Setup Script für Debian 12
# Ausführung in /opt/: sudo bash setup.sh

set -e  # Script bei Fehler beenden

echo "=== Manage IP Setup Script ==="
echo "Installation startet in /opt/manage-ip/"
echo

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNUNG]${NC} $1"
}

print_error() {
    echo -e "${RED}[FEHLER]${NC} $1"
}

# Root-Rechte prüfen
if [ "$EUID" -ne 0 ]; then 
    print_error "Bitte als root ausführen (sudo bash setup.sh)"
    exit 1
fi

# 1. System Update
print_status "System wird aktualisiert..."
apt update && apt upgrade -y

# 2. Abhängigkeiten installieren
print_status "Installiere System-Abhängigkeiten..."
apt install -y python3 python3-pip python3-venv python3-dev build-essential git nginx sqlite3

# 3. Projektordner erstellen
print_status "Erstelle Projektordner..."
cd /opt
rm -rf manage-ip  # Falls bereits vorhanden
mkdir -p manage-ip
cd manage-ip

# 4. Virtual Environment erstellen
print_status "Erstelle Python Virtual Environment..."
python3 -m venv venv
source venv/bin/activate

# 5. Python Dependencies installieren  
print_status "Installiere Python-Pakete..."
pip install --upgrade pip
pip install Django==4.2.11 Pillow==10.2.0

# 6. Django Projekt-Struktur erstellen
print_status "Erstelle Django Projekt-Struktur..."
mkdir -p manage_ip ip_manager templates/ip_manager static/css static/js media

# 7. Alle Dateien erstellen
print_status "Erstelle Django-Dateien..."

# manage.py
cat > manage.py << 'EOF'
#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys


def main():
    """Run administrative tasks."""
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'manage_ip.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()
EOF

# requirements.txt
cat > requirements.txt << 'EOF'
Django==4.2.11
Pillow==10.2.0
EOF

# manage_ip/__init__.py
touch manage_ip/__init__.py

# manage_ip/settings.py
cat > manage_ip/settings.py << 'EOF'
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'django-insecure-change-this-in-production-$(openssl rand -hex 32)'

DEBUG = True

ALLOWED_HOSTS = ['localhost', '127.0.0.1', '*']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'ip_manager',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'manage_ip.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'manage_ip.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

LANGUAGE_CODE = 'de-de'
TIME_ZONE = 'Europe/Berlin'
USE_I18N = True
USE_TZ = True

STATIC_URL = '/static/'
STATICFILES_DIRS = [
    BASE_DIR / 'static',
]
STATIC_ROOT = BASE_DIR / 'staticfiles'

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
EOF

# manage_ip/urls.py
cat > manage_ip/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('ip_manager.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
EOF

# manage_ip/wsgi.py
cat > manage_ip/wsgi.py << 'EOF'
"""
WSGI config for manage_ip project.
"""

import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'manage_ip.settings')
application = get_wsgi_application()
EOF

# ip_manager/__init__.py
touch ip_manager/__init__.py

# ip_manager/apps.py
cat > ip_manager/apps.py << 'EOF'
from django.apps import AppConfig

class IpManagerConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'ip_manager'
    verbose_name = 'IP Manager'
EOF

# ip_manager/models.py (ERWEITERT mit Beschreibung)
cat > ip_manager/models.py << 'EOF'
from django.db import models

class AddressRange(models.Model):
    name = models.CharField(max_length=100, unique=True, verbose_name="Adressbereich")
    description = models.CharField(max_length=200, blank=True, verbose_name="Beschreibung")
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Adressbereich"
        verbose_name_plural = "Adressbereiche"
        ordering = ['name']
    
    def __str__(self):
        return f"{self.name} ({self.description})" if self.description else self.name

class IPAddress(models.Model):
    address_range = models.ForeignKey(AddressRange, on_delete=models.CASCADE, related_name='ip_addresses')
    ip_address = models.CharField(max_length=15, verbose_name="IP-Adresse")
    device_name = models.CharField(max_length=200, verbose_name="Gerätename", blank=True)
    software = models.CharField(max_length=200, verbose_name="Software", blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = "IP-Adresse"
        verbose_name_plural = "IP-Adressen"
        unique_together = ['address_range', 'ip_address']
        ordering = ['ip_address']
    
    def __str__(self):
        return f"{self.ip_address} ({self.device_name})"
EOF

# ip_manager/admin.py
cat > ip_manager/admin.py << 'EOF'
from django.contrib import admin
from .models import AddressRange, IPAddress

@admin.register(AddressRange)
class AddressRangeAdmin(admin.ModelAdmin):
    list_display = ['name', 'description', 'created_at']
    search_fields = ['name', 'description']
    ordering = ['name']

@admin.register(IPAddress)
class IPAddressAdmin(admin.ModelAdmin):
    list_display = ['ip_address', 'device_name', 'software', 'address_range', 'created_at']
    list_filter = ['address_range', 'created_at']
    search_fields = ['ip_address', 'device_name', 'software']
    ordering = ['address_range', 'ip_address']
EOF

# ip_manager/views.py (ERWEITERT)
cat > ip_manager/views.py << 'EOF'
from django.shortcuts import render, redirect, get_object_or_404
from django.http import JsonResponse
from django.contrib import messages
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from .models import AddressRange, IPAddress
import json

def index(request):
    """Hauptseite mit allen Adressbereichen"""
    address_ranges = AddressRange.objects.all()
    selected_range = None
    ip_addresses = []
    
    if request.GET.get('range_id'):
        try:
            selected_range = AddressRange.objects.get(id=request.GET.get('range_id'))
            ip_addresses = IPAddress.objects.filter(address_range=selected_range)
        except AddressRange.DoesNotExist:
            pass
    
    context = {
        'address_ranges': address_ranges,
        'selected_range': selected_range,
        'ip_addresses': ip_addresses,
    }
    return render(request, 'ip_manager/index.html', context)

@require_POST
def add_address_range(request):
    """Neuen Adressbereich hinzufügen"""
    range_name = request.POST.get('range_name', '').strip()
    description = request.POST.get('description', '').strip()
    
    if range_name:
        try:
            AddressRange.objects.create(name=range_name, description=description)
            messages.success(request, f'Adressbereich "{range_name}" wurde erfolgreich erstellt.')
        except Exception as e:
            messages.error(request, f'Fehler beim Erstellen des Adressbereichs: {str(e)}')
    else:
        messages.error(request, 'Bitte geben Sie einen gültigen Adressbereich ein.')
    
    return redirect('index')

@require_POST
def delete_address_range(request, range_id):
    """Adressbereich löschen"""
    try:
        address_range = get_object_or_404(AddressRange, id=range_id)
        range_name = address_range.name
        address_range.delete()
        messages.success(request, f'Adressbereich "{range_name}" wurde gelöscht.')
    except Exception as e:
        messages.error(request, f'Fehler beim Löschen: {str(e)}')
    
    return redirect('index')

@require_POST
def add_ip_address(request):
    """Neue IP-Adresse hinzufügen"""
    range_id = request.POST.get('range_id')
    ip_address = request.POST.get('ip_address', '').strip()
    device_name = request.POST.get('device_name', '').strip()
    software = request.POST.get('software', '').strip()
    
    if range_id and ip_address:
        try:
            address_range = get_object_or_404(AddressRange, id=range_id)
            IPAddress.objects.create(
                address_range=address_range,
                ip_address=ip_address,
                device_name=device_name,
                software=software
            )
            messages.success(request, f'IP-Adresse "{ip_address}" wurde erfolgreich hinzugefügt.')
        except Exception as e:
            messages.error(request, f'Fehler beim Hinzufügen der IP-Adresse: {str(e)}')
    else:
        messages.error(request, 'Bitte geben Sie eine gültige IP-Adresse ein.')
    
    return redirect(f'/?range_id={range_id}')

@require_POST
def delete_ip_address(request, ip_id):
    """IP-Adresse löschen"""
    try:
        ip_address = get_object_or_404(IPAddress, id=ip_id)
        range_id = ip_address.address_range.id
        ip_addr = ip_address.ip_address
        ip_address.delete()
        messages.success(request, f'IP-Adresse "{ip_addr}" wurde gelöscht.')
        return redirect(f'/?range_id={range_id}')
    except Exception as e:
        messages.error(request, f'Fehler beim Löschen: {str(e)}')
        return redirect('index')
EOF

# ip_manager/urls.py
cat > ip_manager/urls.py << 'EOF'
from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('add-range/', views.add_address_range, name='add_address_range'),
    path('delete-range/<int:range_id>/', views.delete_address_range, name='delete_address_range'),
    path('add-ip/', views.add_ip_address, name='add_ip_address'),
    path('delete-ip/<int:ip_id>/', views.delete_ip_address, name='delete_ip_address'),
]
EOF

# 8. CSS-Datei erstellen (MIT ALLEN FIXES)
print_status "Erstelle CSS-Datei..."
cat > static/css/style.css << 'EOF'
/* Manage IP - Hauptstil-Datei */

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f5f5f5;
    color: #333;
}

/* Header Styles */
.header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 1rem 2rem;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.header img {
    height: 50px;
    width: auto;
}

/* Container */
.container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 20px;
}

/* Box 1 - Beschreibung */
.description-box {
    background: white;
    padding: 20px;
    margin-bottom: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    border-left: 4px solid #667eea;
}

.description-box h2 {
    color: #667eea;
    margin-bottom: 10px;
}

/* Main Content Layout */
.main-content {
    display: flex;
    gap: 20px;
    min-height: 600px;
}

/* Box 2 - Adressbereiche (30%) */
.address-ranges-box {
    flex: 0 0 30%;
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    display: flex;
    flex-direction: column;
}

.address-ranges-header {
    background: #f8f9fa;
    padding: 15px;
    border-bottom: 1px solid #e9ecef;
    border-radius: 8px 8px 0 0;
}

.address-ranges-content {
    flex: 1;
    padding: 15px;
    overflow-y: auto;
}

.address-ranges-footer {
    padding: 15px;
    border-top: 1px solid #e9ecef;
    background: #f8f9fa;
    border-radius: 0 0 8px 8px;
}

/* Box 3 - IP Details (70%) */
.ip-details-box {
    flex: 0 0 70%;
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    display: flex;
    flex-direction: column;
}

.ip-details-header {
    background: #f8f9fa;
    padding: 15px;
    border-bottom: 1px solid #e9ecef;
    border-radius: 8px 8px 0 0;
}

.ip-details-content {
    flex: 1;
    padding: 15px;
    overflow-y: auto;
}

/* Form Styles */
.form-group {
    margin-bottom: 15px;
}

.form-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: 600;
    color: #555;
}

.form-control {
    width: 100%;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 14px;
}

.form-control:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.2);
}

/* Button Styles */
.btn {
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    text-decoration: none;
    display: inline-block;
    margin-right: 10px;
    transition: all 0.3s ease;
}

.btn-primary {
    background-color: #667eea;
    color: white;
}

.btn-primary:hover {
    background-color: #5a67d8;
}

.btn-danger {
    background-color: #e53e3e;
    color: white;
}

.btn-danger:hover {
    background-color: #c53030;
}

.btn-small {
    padding: 5px 10px;
    font-size: 12px;
}

/* Range Item - REPARIERT */
.range-item {
    background: #f8f9fa;
    border: 1px solid #e9ecef;
    border-radius: 4px;
    padding: 12px;
    margin-bottom: 10px;
    transition: all 0.3s ease;
}

.range-item:hover {
    background: #e9ecef;
    border-color: #667eea;
}

.range-item.active {
    background: #667eea;
    color: white;
    border-color: #667eea;
}

.range-item-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.range-item-content {
    flex: 1;
    cursor: pointer;
}

.range-item-content:hover {
    opacity: 0.8;
}

.range-description {
    font-size: 12px;
    color: #666;
    margin-top: 5px;
}

.range-item.active .range-description {
    color: #e6e6e6;
}

/* IP Address Item */
.ip-item {
    background: #f8f9fa;
    border: 1px solid #e9ecef;
    border-radius: 4px;
    padding: 15px;
    margin-bottom: 10px;
}

.ip-item-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 10px;
}

.ip-address {
    font-weight: 600;
    color: #667eea;
    font-size: 16px;
}

.ip-details {
    color: #666;
    font-size: 14px;
}

/* Messages */
.messages {
    margin-bottom: 20px;
}

.message {
    padding: 12px;
    border-radius: 4px;
    margin-bottom: 10px;
}

.message.success {
    background-color: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
}

.message.error {
    background-color: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
}

/* Empty State */
.empty-state {
    text-align: center;
    padding: 40px;
    color: #666;
}

.empty-state h3 {
    margin-bottom: 10px;
    color: #999;
}

/* Responsive Design */
@media (max-width: 768px) {
    .main-content {
        flex-direction: column;
    }
    
    .address-ranges-box,
    .ip-details-box {
        flex: none;
    }
}

/* Farbschema Variablen für einfache Anpassungen */
:root {
    --primary-color: #667eea;
    --primary-dark: #5a67d8;
    --danger-color: #e53e3e;
    --danger-dark: #c53030;
    --background-color: #f5f5f5;
    --card-background: white;
    --border-color: #e9ecef;
    --text-color: #333;
    --text-muted: #666;
}
EOF

# 9. Templates erstellen
print_status "Erstelle HTML-Templates..."

# base.html
cat > templates/base.html << 'EOF'
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}Manage IP{% endblock %}</title>
    {% load static %}
    <link rel="stylesheet" href="{% static 'css/style.css' %}">
</head>
<body>
    <!-- Header -->
    <header class="header">
        <img src="{% static 'media/logo.png' %}" alt="Manage IP Logo" onerror="this.style.display='none';">
    </header>

    <!-- Main Container -->
    <div class="container">
        <!-- Messages -->
        {% if messages %}
            <div class="messages">
                {% for message in messages %}
                    <div class="message {{ message.tags }}">
                        {{ message }}
                    </div>
                {% endfor %}
            </div>
        {% endif %}

        {% block content %}
        {% endblock %}
    </div>
</body>
</html>
EOF

# index.html (REPARIERT - Geräte funktioniert)
cat > templates/ip_manager/index.html << 'EOF'
{% extends 'base.html' %}
{% load static %}

{% block content %}
<!-- Box 1 - Beschreibung -->
<div class="description-box">
    <h2>IP-Adressverwaltung</h2>
    <p>Hier kannst du deine IP-Adressbereiche und einzelne IP-Adressen übersichtlich verwalten. Erstelle zunächst in der linken Spalte einen      Adressbereich (z. B. „192.168.1.X") mit einer passenden Beschreibung. Anschließend kannst du in der rechten Spalte einzelne IP-Adressen mit Geräteinformationen und Softwareeinträgen hinzufügen. <br>Weitere Infos: <a href="https://bennystechblog.de" target="_blank">Bennys Techblog</a> und <a href="https://github.com/benne1987" target="_blank">Github</a></p>
</div>

<!-- Main Content -->
<div class="main-content">
    <!-- Box 2 - Adressbereiche (30%) -->
    <div class="address-ranges-box">
        <div class="address-ranges-header">
            <h3>Adressbereiche</h3>
        </div>
        
        <div class="address-ranges-content">
            {% if address_ranges %}
                {% for range in address_ranges %}
                    <div class="range-item {% if selected_range and range.id == selected_range.id %}active{% endif %}">
                        <div class="range-item-header">
                            <div onclick="selectRange({{ range.id }})" style="cursor: pointer; flex: 1;">
                                <div><strong>{{ range.name }}</strong></div>
                                {% if range.description %}
                                    <div class="range-description">{{ range.description }}</div>
                                {% endif %}
                            </div>
                            <form method="post" action="{% url 'delete_address_range' range.id %}" 
                                  style="display: inline;" 
                                  onsubmit="return confirm('Adressbereich \'{{ range.name }}\' wirklich löschen?');"
                                  onclick="event.stopPropagation();">
                                {% csrf_token %}
                                <button type="submit" class="btn btn-danger btn-small" onclick="event.stopPropagation();">Löschen</button>
                            </form>
                        </div>
                    </div>
                {% endfor %}
            {% else %}
                <div class="empty-state">
                    <h3>Keine Adressbereiche</h3>
                    <p>Erstelle unten den ersten Adressbereich.</p>
                </div>
            {% endif %}
        </div>
        
        <div class="address-ranges-footer">
            <form method="post" action="{% url 'add_address_range' %}">
                {% csrf_token %}
                <div class="form-group">
                    <label for="range_name">Neuer Adressbereich:</label>
                    <input type="text" 
                           id="range_name" 
                           name="range_name" 
                           class="form-control" 
                           placeholder="z.B. 192.168.1.X"
                           required>
                </div>
                <div class="form-group">
                    <label for="description">Beschreibung:</label>
                    <input type="text" 
                           id="description" 
                           name="description" 
                           class="form-control" 
                           placeholder="z.B. Kameranetz">
                </div>
                <button type="submit" class="btn btn-primary">Speichern</button>
            </form>
        </div>
    </div>
    
    <!-- Box 3 - IP Details (70%) -->
    <div class="ip-details-box">
        <div class="ip-details-header">
            <h3>
                {% if selected_range %}
                    IP-Adressen für {{ selected_range.name }}
                    {% if selected_range.description %}
                        <small>({{ selected_range.description }})</small>
                    {% endif %}
                {% else %}
                    IP-Adressen verwalten
                {% endif %}
            </h3>
        </div>
        
        <div class="ip-details-content">
            {% if selected_range %}
                <!-- IP-Adresse hinzufügen Form -->
                <form method="post" action="{% url 'add_ip_address' %}" style="margin-bottom: 30px;">
                    {% csrf_token %}
                    <input type="hidden" name="range_id" value="{{ selected_range.id }}">
                    
                    <div style="display: flex; gap: 15px; margin-bottom: 15px;">
                        <div class="form-group" style="flex: 1;">
                            <label for="ip_address">IP-Adresse:</label>
                            <input type="text" 
                                   id="ip_address" 
                                   name="ip_address" 
                                   class="form-control" 
                                   placeholder="z.B. 192.168.1.10"
                                   required>
                        </div>
                        
                        <div class="form-group" style="flex: 1;">
                            <label for="device_name">Gerätename:</label>
                            <input type="text" 
                                   id="device_name" 
                                   name="device_name" 
                                   class="form-control" 
                                   placeholder="z.B. Server-01">
                        </div>
                        
                        <div class="form-group" style="flex: 1;">
                            <label for="software">Software:</label>
                            <input type="text" 
                                   id="software" 
                                   name="software" 
                                   class="form-control" 
                                   placeholder="z.B. Ubuntu 22.04">
                        </div>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">IP-Adresse speichern</button>
                </form>
                
                <hr style="margin: 30px 0; border: 0; border-top: 1px solid #e9ecef;">
                
                <!-- IP-Adressen Liste -->
                {% if ip_addresses %}
                    {% for ip in ip_addresses %}
                        <div class="ip-item">
                            <div class="ip-item-header">
                                <div>
                                    <div class="ip-address">{{ ip.ip_address }}</div>
                                    <div class="ip-details">
                                        {% if ip.device_name %}
                                            <strong>Gerät:</strong> {{ ip.device_name }}<br>
                                        {% endif %}
                                        {% if ip.software %}
                                            <strong>Software:</strong> {{ ip.software }}<br>
                                        {% endif %}
                                        <strong>Erstellt:</strong> {{ ip.created_at|date:"d.m.Y H:i" }}
                                    </div>
                                </div>
                                <form method="post" action="{% url 'delete_ip_address' ip.id %}" 
                                      onsubmit="return confirm('IP-Adresse \'{{ ip.ip_address }}\' wirklich löschen?');">
                                    {% csrf_token %}
                                    <button type="submit" class="btn btn-danger btn-small">Löschen</button>
                                </form>
                            </div>
                        </div>
                    {% endfor %}
                {% else %}
                    <div class="empty-state">
                        <h3>Keine IP-Adressen</h3>
                        <p>Füge oben die erste IP-Adresse für diesen Bereich hinzu.</p>
                    </div>
                {% endif %}
                
            {% else %}
                <div class="empty-state">
                    <h3>Kein Adressbereich ausgewählt</h3>
                    <p>Wähle links einen Adressbereich aus oder erstelle einen neuen.</p>
                </div>
            {% endif %}
        </div>
    </div>
</div>

<script>
function selectRange(rangeId) {
    window.location.href = '/?range_id=' + rangeId;
}
</script>
{% endblock %}
EOF

# 10. Logo-Platzhalter erstellen
print_status "Erstelle Logo-Platzhalter..."
mkdir -p static/media
echo "<!-- Platzieren Sie hier Ihr logo.png -->" > static/media/README.txt

# 11. Berechtigungen setzen (vor Django-Setup!)
print_status "Setze initiale Dateiberechtigungen..."
chmod +x manage.py

# 12. Django Setup
print_status "Führe Django-Setup aus..."
source venv/bin/activate
python manage.py makemigrations ip_manager
python manage.py migrate

# 13. Superuser erstellen
print_status "Erstelle Django Superuser..."
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@localhost', 'admin123') if not User.objects.filter(username='admin').exists() else None" | python manage.py shell

# 14. Statische Dateien sammeln
print_status "Sammle statische Dateien..."
python manage.py collectstatic --noinput

# 15. Endgültige Berechtigungen setzen
print_status "Setze finale Berechtigungen für Produktionsbetrieb..."
# Ordner-Eigentümer auf www-data setzen
chown -R www-data:www-data /opt/manage-ip

# Spezielle Berechtigungen für Datenbank und Media-Ordner
chmod 664 /opt/manage-ip/db.sqlite3
chmod 775 /opt/manage-ip/media
chmod 775 /opt/manage-ip/static
chmod 775 /opt/manage-ip/staticfiles

# Verzeichnis-Berechtigungen
find /opt/manage-ip -type d -exec chmod 755 {} \;
find /opt/manage-ip -type f -exec chmod 644 {} \;

# Ausführbare Dateien
chmod +x /opt/manage-ip/manage.py
chmod +x /opt/manage-ip/venv/bin/*

# SQLite-Datei und Verzeichnis müssen von www-data beschreibbar sein
chown www-data:www-data /opt/manage-ip/db.sqlite3
chown www-data:www-data /opt/manage-ip

# 16. Systemd Service erstellen
print_status "Erstelle Systemd-Service..."
cat > /etc/systemd/system/manage-ip.service << 'EOF'
[Unit]
Description=Manage IP Django Application
After=network.target

[Service]
Type=exec
User=www-data
Group=www-data
WorkingDirectory=/opt/manage-ip
Environment="PATH=/opt/manage-ip/venv/bin"
ExecStart=/opt/manage-ip/venv/bin/python manage.py runserver 0.0.0.0:8000
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# 17. Nginx Konfiguration
print_status "Konfiguriere Nginx..."
cat > /etc/nginx/sites-available/manage-ip << 'EOF'
server {
    listen 80;
    server_name _;
    
    location /static/ {
        alias /opt/manage-ip/staticfiles/;
    }
    
    location /media/ {
        alias /opt/manage-ip/media/;
    }
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Nginx-Site aktivieren
ln -sf /etc/nginx/sites-available/manage-ip /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl reload nginx

# 18. Services starten
print_status "Starte Services..."
systemctl daemon-reload
systemctl enable manage-ip
systemctl start manage-ip
systemctl enable nginx
systemctl restart nginx

# 19. Firewall konfigurieren (optional)
if command -v ufw &> /dev/null; then
    print_status "Konfiguriere Firewall..."
    ufw allow 80/tcp
    ufw allow 22/tcp
    ufw --force enable
fi

# 20. Installation abgeschlossen
print_status "Installation erfolgreich abgeschlossen!"
echo
echo "========================================="
echo "  MANAGE IP INSTALLATION ABGESCHLOSSEN  "
echo "========================================="
echo
echo "📁 Projektordner: /opt/manage-ip"
echo "🌐 Web-Interface: http://$(hostname -I | awk '{print $1}')"
echo "🔧 Admin-Interface: http://$(hostname -I | awk '{print $1}')/admin/"
echo "👤 Admin-Login: admin / admin123"
echo
echo "📋 WICHTIGE NÄCHSTE SCHRITTE:"
echo "1. Admin-Passwort ändern: /opt/manage-ip/venv/bin/python /opt/manage-ip/manage.py changepassword admin"
echo
echo "🔧 BEFEHLE:"
echo "- Service starten: systemctl start manage-ip"
echo "- Service stoppen: systemctl stop manage-ip"
echo "- Logs anzeigen: journalctl -u manage-ip -f"
echo "- Django Shell: cd /opt/manage-ip && source venv/bin/activate && python manage.py shell"
echo
echo
echo "🎉 Das System ist jetzt unter http://$(hostname -I | awk '{print $1}') erreichbar!" if ip.device_name %}
                                            <strong>Gerät:</strong> {{ ip.device_name }}<br>
                                        {% endif %}
                                        
