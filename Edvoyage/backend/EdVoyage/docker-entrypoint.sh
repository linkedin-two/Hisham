#!/bin/sh
set -e

echo "=== [Edvoyage Backend] Starting Initialization ==="

# If persistent volume path is specified and file doesn't exist yet, copy template db if present
if [ -n "$SQLITE_DB_PATH" ] && [ ! -f "$SQLITE_DB_PATH" ] && [ -f "/app/db.sqlite3" ]; then
    echo "[Info] Copying initial sqlite database to persistent volume ($SQLITE_DB_PATH)..."
    mkdir -p "$(dirname "$SQLITE_DB_PATH")"
    cp "/app/db.sqlite3" "$SQLITE_DB_PATH"
fi

# Apply database migrations
echo "[1/2] Running database migrations..."
python manage.py migrate --no-input

# Collect static files for WhiteNoise
echo "[2/2] Collecting static files..."
python manage.py collectstatic --no-input

echo "Starting Gunicorn server on 0.0.0.0:8000..."
exec gunicorn edvoayge.wsgi:application \
    -c gunicorn.conf.py \
    --bind 0.0.0.0:8000
