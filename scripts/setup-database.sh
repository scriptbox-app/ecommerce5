#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

if [[ ! -f .env ]]; then
  cp .env.example .env
  php artisan key:generate
fi

bash scripts/start-mysql.sh

echo "Installing database schema and seed data (this may take several minutes)..."
php artisan app:install

php artisan storage:link 2>/dev/null || true

echo ""
echo "Database setup complete."
echo "  Admin:  http://127.0.0.1:8000/login"
echo "          sabbir.techvill@gmail.com / 12345678"
echo "  Store:  http://127.0.0.1:8000/customer"
echo "          sabbir@gmail.com / 123456"
echo ""
echo "Start the app: php artisan serve"
