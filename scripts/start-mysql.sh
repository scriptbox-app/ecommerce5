#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${ROOT}/.mysql-local/data"
RUN_DIR="${ROOT}/.mysql-local/run"
PORT="${MYSQL_LOCAL_PORT:-3307}"

mkdir -p "${DATA_DIR}" "${RUN_DIR}" "${ROOT}/.mysql-local/tmp"

if [[ ! -f "${DATA_DIR}/ibdata1" ]]; then
  echo "Initializing local MySQL data directory..."
  mysqld --initialize-insecure --datadir="${DATA_DIR}" --basedir=/usr
fi

if [[ -S "${RUN_DIR}/mysqld.sock" ]] && mysqladmin -S "${RUN_DIR}/mysqld.sock" -u root ping &>/dev/null; then
  echo "Local MySQL already running on port ${PORT}."
  exit 0
fi

echo "Starting local MySQL on port ${PORT}..."
mysqld \
  --datadir="${DATA_DIR}" \
  --socket="${RUN_DIR}/mysqld.sock" \
  --pid-file="${RUN_DIR}/mysqld.pid" \
  --port="${PORT}" \
  --bind-address=127.0.0.1 \
  --skip-log-bin &

for _ in $(seq 1 30); do
  if mysqladmin -S "${RUN_DIR}/mysqld.sock" -u root ping &>/dev/null; then
    mysql -S "${RUN_DIR}/mysqld.sock" -u root -e \
      "CREATE DATABASE IF NOT EXISTS ecommerce5 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" &>/dev/null || true
    echo "Local MySQL is ready (socket: ${RUN_DIR}/mysqld.sock, port: ${PORT})."
    exit 0
  fi
  sleep 1
done

echo "MySQL failed to start within 30 seconds." >&2
exit 1
