#!/bin/sh
set -e

echo "=== [Edzkool Backend] Starting Initialization ==="

# If persistent volume path is specified and file doesn't exist yet, copy existing sqlite db
if [ -n "$SQLITE_DB_PATH" ] && [ ! -f "$SQLITE_DB_PATH" ] && [ -f "/app/edzkool_db.sqlite3" ]; then
    echo "[Info] Copying initial sqlite database to persistent volume ($SQLITE_DB_PATH)..."
    mkdir -p "$(dirname "$SQLITE_DB_PATH")"
    cp "/app/edzkool_db.sqlite3" "$SQLITE_DB_PATH"
fi

# Apply database migrations
echo "[1/3] Running database migrations..."
python manage.py migrate --no-input

# Collect static files for WhiteNoise
echo "[2/3] Collecting static files..."
python manage.py collectstatic --no-input

# Optional seed database (if SEED_DATABASE is true)
if [ "$SEED_DATABASE" = "true" ] || [ "$SEED_DATABASE" = "True" ]; then
    if [ -f "seed_database.py" ]; then
        echo "[Optional] Seeding database..."
        python seed_database.py || true
    fi
fi

echo "[3/3] Starting Gunicorn server on 0.0.0.0:8000..."
exec gunicorn edvoayge.wsgi:application \
    -c gunicorn.conf.py \
    --bind 0.0.0.0:8000
