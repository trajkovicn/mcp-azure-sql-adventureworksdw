#!/usr/bin/env bash
set -euo pipefail

# Seeds a minimal AdventureWorksDW-like dataset into your Azure SQL Database.
# Requires: Python + ODBC Driver 18 + pyodbc (installed via server/requirements.txt)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python -m venv "$ROOT_DIR/.venv" 2>/dev/null || true
source "$ROOT_DIR/.venv/bin/activate"

pip install -r "$ROOT_DIR/server/requirements.txt" >/dev/null
python "$ROOT_DIR/seed/seed_minidw.py"
