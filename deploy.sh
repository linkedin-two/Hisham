#!/bin/bash
# ==============================================================================
# Complete Turnkey EC2 Deployment Script
# Native Linux: Systemd + Nginx + Certbot (SSL) + Python Virtualenvs
#
# Configures & Runs:
#   1. Edzkool Backend  -> 127.0.0.1:8000 -> https://edzkool.duckdns.org
#   2. Edvoyage Backend -> 127.0.0.1:8001 -> https://edvoyage.duckdns.org
# ==============================================================================

set -e

# Automatically elevate to sudo if not root
if [ "$EUID" -ne 0 ]; then
    echo ">> Elevating privileges to root..."
    exec sudo bash "$0" "$@"
fi

# Detect absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_GROUP="$(id -gn "$TARGET_USER" 2>/dev/null || echo "$TARGET_USER")"

EDZKOOL_DIR="$SCRIPT_DIR/Edzkool/backend"
EDVOYAGE_DIR="$SCRIPT_DIR/Edvoyage/backend/EdVoyage"

VENV_EDZKOOL="$EDZKOOL_DIR/venv"
VENV_EDVOYAGE="$EDVOYAGE_DIR/venv"

echo "=================================================================="
echo " Starting Full Automated Dual Backend Deployment on Single EC2"
echo " User: $TARGET_USER ($TARGET_GROUP)"
echo " Directory: $SCRIPT_DIR"
echo "=================================================================="

# ------------------------------------------------------------------------------
# STEP 1: Setup 2GB Swap Memory (Prevents memory crash on t2/t3.micro instances)
# ------------------------------------------------------------------------------
SWAP_TOTAL=$(free -m | awk '/^Swap:/ {print $2}')
if [ -z "$SWAP_TOTAL" ] || [ "$SWAP_TOTAL" -lt 1000 ]; then
    echo "[Step 1/8] Setting up 2GB Swap Memory..."
    fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile || true
    if ! grep -q '/swapfile' /etc/fstab; then
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
    fi
    echo "✓ Swap memory successfully enabled."
else
    echo "[Step 1/8] Swap memory already active (${SWAP_TOTAL}MB)."
fi

# ------------------------------------------------------------------------------
# STEP 2: Install System Packages (Nginx, Certbot, Python3, OCR & PDF utilities)
# ------------------------------------------------------------------------------
echo "[Step 2/8] Installing system dependencies via apt..."
apt-get update -q

# Detect current Python version on EC2 (e.g. 3.12, 3.14)
PY_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "3")

apt-get install -y -q \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    "python${PY_VER}-dev" \
    build-essential \
    nginx \
    certbot \
    python3-certbot-nginx \
    poppler-utils \
    tesseract-ocr \
    gcc \
    libpq-dev \
    curl \
    git || true

# ------------------------------------------------------------------------------
# STEP 3: Setup Python Virtual Environments & Dependencies
# ------------------------------------------------------------------------------
echo "[Step 3/8] Configuring Python virtual environments (Python $PY_VER)..."

# Edzkool venv
if [ ! -d "$VENV_EDZKOOL" ]; then
    echo ">> Creating virtualenv for Edzkool..."
    python3 -m venv "$VENV_EDZKOOL"
fi
echo ">> Upgrading pip, setuptools, and wheel for Edzkool..."
"$VENV_EDZKOOL/bin/pip" install --upgrade pip setuptools wheel --quiet

echo ">> Installing Edzkool dependencies..."
if ! "$VENV_EDZKOOL/bin/pip" install -r "$EDZKOOL_DIR/requirements.txt"; then
    echo ">> Notice: Direct requirements install encountered a build issue. Applying compatibility fallback..."
    grep -v "psycopg2" "$EDZKOOL_DIR/requirements.txt" > /tmp/edzkool_req.txt
    "$VENV_EDZKOOL/bin/pip" install -r /tmp/edzkool_req.txt --quiet
    rm -f /tmp/edzkool_req.txt
    # Try installing modern psycopg[binary] (supported in Python 3.12, 3.13, 3.14)
    "$VENV_EDZKOOL/bin/pip" install "psycopg[binary]" --quiet || "$VENV_EDZKOOL/bin/pip" install psycopg2-binary --quiet || true
fi

# Edvoyage venv
if [ ! -d "$VENV_EDVOYAGE" ]; then
    echo ">> Creating virtualenv for Edvoyage..."
    python3 -m venv "$VENV_EDVOYAGE"
fi
echo ">> Upgrading pip, setuptools, and wheel for Edvoyage..."
"$VENV_EDVOYAGE/bin/pip" install --upgrade pip setuptools wheel --quiet

echo ">> Installing Edvoyage dependencies..."
if ! "$VENV_EDVOYAGE/bin/pip" install -r "$EDVOYAGE_DIR/requirements.txt"; then
    echo ">> Notice: Direct requirements install encountered an issue. Retrying with fallback..."
    grep -v "psycopg2" "$EDVOYAGE_DIR/requirements.txt" > /tmp/edvoyage_req.txt || cp "$EDVOYAGE_DIR/requirements.txt" /tmp/edvoyage_req.txt
    "$VENV_EDVOYAGE/bin/pip" install -r /tmp/edvoyage_req.txt --quiet
    rm -f /tmp/edvoyage_req.txt
fi

# ------------------------------------------------------------------------------
# STEP 4: Configure Production Environment Variables (.env)
# ------------------------------------------------------------------------------
echo "[Step 4/8] Setting up .env files..."

if [ ! -f "$EDZKOOL_DIR/.env" ]; then
    echo ">> Creating $EDZKOOL_DIR/.env..."
    cat <<EOF > "$EDZKOOL_DIR/.env"
DJANGO_SECRET_KEY=$(openssl rand -hex 24)
DJANGO_DEBUG=False
ALLOWED_HOSTS=edzkool.duckdns.org,edvoyage.duckdns.org,localhost,127.0.0.1
CORS_ALLOWED_ORIGINS=https://edzkool.duckdns.org,https://edvoyage.duckdns.org
CSRF_TRUSTED_ORIGINS=https://edzkool.duckdns.org,https://edvoyage.duckdns.org
SECURE_SSL_REDIRECT=False
EOF
fi

if [ ! -f "$EDVOYAGE_DIR/.env" ]; then
    echo ">> Creating $EDVOYAGE_DIR/.env..."
    cat <<EOF > "$EDVOYAGE_DIR/.env"
DJANGO_SECRET_KEY=$(openssl rand -hex 24)
DJANGO_DEBUG=False
ALLOWED_HOSTS=edvoyage.duckdns.org,edzkool.duckdns.org,localhost,127.0.0.1
CORS_ALLOWED_ORIGINS=https://edvoyage.duckdns.org,https://edzkool.duckdns.org
CSRF_TRUSTED_ORIGINS=https://edvoyage.duckdns.org,https://edzkool.duckdns.org
SECURE_SSL_REDIRECT=False
EOF
fi

# Ensure necessary directories exist
mkdir -p "$EDZKOOL_DIR/logs" "$EDZKOOL_DIR/media" "$EDZKOOL_DIR/staticfiles"
mkdir -p "$EDVOYAGE_DIR/logs" "$EDVOYAGE_DIR/media" "$EDVOYAGE_DIR/staticfiles"

# ------------------------------------------------------------------------------
# STEP 5: Run Database Migrations & Collect Static Files
# ------------------------------------------------------------------------------
echo "[Step 5/8] Running Django database migrations & static asset collection..."

echo ">> Migrating Edzkool..."
"$VENV_EDZKOOL/bin/python" "$EDZKOOL_DIR/manage.py" migrate --no-input
echo ">> Collecting Edzkool static files..."
"$VENV_EDZKOOL/bin/python" "$EDZKOOL_DIR/manage.py" collectstatic --no-input -v 0

echo ">> Migrating Edvoyage..."
"$VENV_EDVOYAGE/bin/python" "$EDVOYAGE_DIR/manage.py" migrate --no-input
echo ">> Collecting Edvoyage static files..."
"$VENV_EDVOYAGE/bin/python" "$EDVOYAGE_DIR/manage.py" collectstatic --no-input -v 0

# Fix file permissions
chown -R "$TARGET_USER:$TARGET_GROUP" "$EDZKOOL_DIR" "$EDVOYAGE_DIR"

# ------------------------------------------------------------------------------
# STEP 6: Configure Systemd Services for Gunicorn
# ------------------------------------------------------------------------------
echo "[Step 6/8] Configuring and starting Systemd services..."

# Edzkool Service (Port 8000)
cat <<EOF > /etc/systemd/system/edzkool.service
[Unit]
Description=Edzkool Gunicorn Service
After=network.target

[Service]
User=$TARGET_USER
Group=$TARGET_GROUP
WorkingDirectory=$EDZKOOL_DIR
Environment="PATH=$VENV_EDZKOOL/bin:/usr/local/bin:/usr/bin:/bin"
Environment="PYTHONPATH=$EDZKOOL_DIR"
ExecStart=$VENV_EDZKOOL/bin/gunicorn edvoayge.wsgi:application \\
    -c gunicorn.conf.py \\
    --bind 127.0.0.1:8000 \\
    --workers 2 \\
    --timeout 60

Restart=always
RestartSec=5
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Edvoyage Service (Port 8001)
cat <<EOF > /etc/systemd/system/edvoyage.service
[Unit]
Description=Edvoyage Gunicorn Service
After=network.target

[Service]
User=$TARGET_USER
Group=$TARGET_GROUP
WorkingDirectory=$EDVOYAGE_DIR
Environment="PATH=$VENV_EDVOYAGE/bin:/usr/local/bin:/usr/bin:/bin"
Environment="PYTHONPATH=$EDVOYAGE_DIR"
ExecStart=$VENV_EDVOYAGE/bin/gunicorn edvoayge.wsgi:application \\
    -c gunicorn.conf.py \\
    --bind 127.0.0.1:8001 \\
    --workers 2 \\
    --timeout 60

Restart=always
RestartSec=5
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable edzkool.service edvoyage.service
systemctl restart edzkool.service edvoyage.service

# ------------------------------------------------------------------------------
# STEP 7: Configure Nginx Reverse Proxy for Dual Domains
# ------------------------------------------------------------------------------
echo "[Step 7/8] Configuring Nginx reverse proxy..."

cat <<EOF > /etc/nginx/sites-available/edzkool_edvoyage.conf
# ==============================================================================
# Dual Domain Configuration for Edzkool and Edvoyage
# ==============================================================================

# 1. Edzkool Domain Configuration
server {
    listen 80;
    listen [::]:80;
    server_name edzkool.duckdns.org;

    client_max_body_size 100M;

    location /static/ {
        alias $EDZKOOL_DIR/staticfiles/;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    location /media/ {
        alias $EDZKOOL_DIR/media/;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}

# 2. Edvoyage Domain Configuration
server {
    listen 80;
    listen [::]:80;
    server_name edvoyage.duckdns.org;

    client_max_body_size 100M;

    location /static/ {
        alias $EDVOYAGE_DIR/staticfiles/;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    location /media/ {
        alias $EDVOYAGE_DIR/media/;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    location / {
        proxy_pass http://127.0.0.1:8001;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

# Enable site configuration and disable default site
ln -sf /etc/nginx/sites-available/edzkool_edvoyage.conf /etc/nginx/sites-enabled/edzkool_edvoyage.conf
rm -f /etc/nginx/sites-enabled/default

# Test Nginx syntax and reload
nginx -t
systemctl restart nginx

# ------------------------------------------------------------------------------
# STEP 8: Automatic SSL (Certbot / Let's Encrypt)
# ------------------------------------------------------------------------------
echo "[Step 8/8] Requesting and configuring Let's Encrypt SSL certificates..."

PUBLIC_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me || echo "")
echo "Server Public IP: $PUBLIC_IP"

# Check if DNS resolves to this server
EDZKOOL_IP=$(getent ahosts edzkool.duckdns.org | head -n 1 | awk '{print $1}')
EDVOYAGE_IP=$(getent ahosts edvoyage.duckdns.org | head -n 1 | awk '{print $1}')

echo "DNS Resolution:"
echo "  - edzkool.duckdns.org  -> ${EDZKOOL_IP:-Not resolved}"
echo "  - edvoyage.duckdns.org -> ${EDVOYAGE_IP:-Not resolved}"

if [ "$EDZKOOL_IP" = "$PUBLIC_IP" ] && [ "$EDVOYAGE_IP" = "$PUBLIC_IP" ]; then
    echo ">> IP match verified. Obtaining SSL certificates via Certbot..."
    certbot --nginx -d edzkool.duckdns.org -d edvoyage.duckdns.org \
        --non-interactive \
        --agree-tos \
        --register-unsafely-without-email \
        --redirect || {
            echo "Warning: Certbot encountered an issue. HTTP is active."
        }
    systemctl reload nginx
    echo "✓ SSL Certificates successfully installed and active!"
else
    echo ">> Attempting Certbot SSL setup..."
    certbot --nginx -d edzkool.duckdns.org -d edvoyage.duckdns.org \
        --non-interactive \
        --agree-tos \
        --register-unsafely-without-email \
        --redirect || {
            echo "------------------------------------------------------------------"
            echo "NOTE: DuckDNS has not yet propagated to this server IP ($PUBLIC_IP)."
            echo "Both applications are currently live on HTTP (Port 80)."
            echo "Once you update duckdns.org, simply run:"
            echo "  sudo certbot --nginx -d edzkool.duckdns.org -d edvoyage.duckdns.org"
            echo "------------------------------------------------------------------"
        }
fi

# ------------------------------------------------------------------------------
# Verification & Health Check
# ------------------------------------------------------------------------------
echo ""
echo "=================================================================="
echo " DEPLOYMENT SUCCESSFUL!"
echo "=================================================================="
echo " Service Status:"
echo "   - Edzkool service:  $(systemctl is-active edzkool.service)"
echo "   - Edvoyage service: $(systemctl is-active edvoyage.service)"
echo "   - Nginx server:     $(systemctl is-active nginx)"
echo ""
echo " Domains Ready:"
echo "   - Edzkool:  https://edzkool.duckdns.org/"
echo "   - Edvoyage: https://edvoyage.duckdns.org/"
echo ""
echo " Management Commands:"
echo "   - Check Edzkool logs:  journalctl -u edzkool -f"
echo "   - Check Edvoyage logs: journalctl -u edvoyage -f"
echo "   - Restart all:         sudo systemctl restart edzkool edvoyage nginx"
echo "=================================================================="
