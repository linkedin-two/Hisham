#!/usr/bin/env bash
# Pre-deploy security checks for Edzkool backend.
set -o errexit

echo "==> Django deploy configuration check"
python manage.py check --deploy

echo "==> Dependency vulnerability scan (pip-audit)"
if ! command -v pip-audit >/dev/null 2>&1; then
  pip install pip-audit -q
fi
if pip-audit -r requirements.txt; then
  echo "pip-audit: no known vulnerabilities reported"
else
  echo "WARNING: pip-audit reported vulnerabilities — review output above" >&2
  if [ "${SECURITY_CHECK_STRICT:-false}" = "true" ]; then
    exit 1
  fi
fi

echo "==> Security checks completed"
