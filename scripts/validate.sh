#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[validate] checking required files"
required=(
  "$ROOT_DIR/docker/docker-compose.yml"
  "$ROOT_DIR/sql/001_init.sql"
  "$ROOT_DIR/.env.example"
)

for f in "${required[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "[validate] missing file: $f"
    exit 1
  fi
done

echo "[validate] checking docker compose syntax"
docker compose -f "$ROOT_DIR/docker/docker-compose.yml" config >/dev/null

echo "[validate] checking init sql has pgvector extension"
if ! grep -q "CREATE EXTENSION IF NOT EXISTS vector;" "$ROOT_DIR/sql/001_init.sql"; then
  echo "[validate] pgvector extension statement not found"
  exit 1
fi

echo "[validate] success"
