#!/usr/bin/env bash
set -o errexit

# Ensure logs directory exists
mkdir -p logs

# Install system dependencies (best-effort)
# poppler-utils is required by the notes app (pdf2image converts PDFs to flashcard images)
apt-get update && apt-get install -y poppler-utils || true

# Install Python dependencies
pip install -r requirements.txt

# Security checks
bash scripts/security_check.sh || true

# Collect static files
python manage.py collectstatic --no-input

# Run database migrations
python manage.py migrate

# Seed database with initial/dummy data
python seed_database.py
