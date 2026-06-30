#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/docker/docker-compose.yml"

if [[ ! -f "$ROOT_DIR/.env" ]]; then
  cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
fi

set -a
source "$ROOT_DIR/.env"
set +a

echo "[smoke] starting local stack"
docker compose -f "$COMPOSE_FILE" up -d

echo "[smoke] waiting for postgres"
until docker exec ai-devtool-postgres pg_isready -U "${POSTGRES_USER:-ai_devtool}" -d "${POSTGRES_DB:-ai_devtool}" >/dev/null 2>&1; do
  sleep 2
done

echo "[smoke] validating pgvector extension"
docker exec ai-devtool-postgres psql -U "${POSTGRES_USER:-ai_devtool}" -d "${POSTGRES_DB:-ai_devtool}" -c "SELECT extname FROM pg_extension WHERE extname='vector';" >/dev/null

echo "[smoke] checking redis"
docker exec ai-devtool-redis redis-cli ping | grep -q PONG

echo "[smoke] checking ollama"
curl -fsS "http://localhost:${OLLAMA_PORT:-11434}/api/tags" >/dev/null

echo "[smoke] success"
