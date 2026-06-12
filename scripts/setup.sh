#!/usr/bin/env bash
# First-time setup for internal-tools.
# Run once after cloning: bash scripts/setup.sh
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

ok()   { echo -e "  ${GREEN}✓${RESET} $*"; }
warn() { echo -e "  ${YELLOW}!${RESET} $*"; }
fail() { echo -e "  ${RED}✗${RESET} $*"; }

echo ""
echo -e "${BOLD}internal-tools setup${RESET}"
echo "──────────────────────────────────────────────────────"

# ─── Node.js version ──────────────────────────────────────────────────────────
echo ""
echo "Checking Node.js..."
NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1 || echo "0")
if [[ "$NODE_VERSION" -ge 22 ]]; then
  ok "Node.js $(node --version)"
else
  fail "Node.js v22+ required, found: $(node --version 2>/dev/null || echo 'not installed')"
  echo "     Install via: https://nodejs.org or 'nvm install 22'"
  exit 1
fi

# ─── gitleaks ─────────────────────────────────────────────────────────────────
echo ""
echo "Checking gitleaks..."
if command -v gitleaks &>/dev/null; then
  ok "gitleaks $(gitleaks version 2>/dev/null | head -1)"
else
  warn "gitleaks not found — pre-commit secret scanning will be skipped"
  if command -v brew &>/dev/null; then
    read -rp "    Install gitleaks via Homebrew? [y/N] " INSTALL_GL
    if [[ "${INSTALL_GL:-N}" =~ ^[Yy]$ ]]; then
      brew install gitleaks
      ok "gitleaks installed"
    else
      warn "Skipping gitleaks install. Secrets will not be scanned before commits."
    fi
  else
    warn "Homebrew not found. Install gitleaks manually: https://github.com/gitleaks/gitleaks"
  fi
fi

# ─── .env files ───────────────────────────────────────────────────────────────
echo ""
echo "Checking .env files..."
ENV_FILES=("apps/api/.env" "apps/web/.env")
MISSING_ENV=false
for ENV_FILE in "${ENV_FILES[@]}"; do
  EXAMPLE="${ENV_FILE}.example"
  if [[ ! -f "$ENV_FILE" ]]; then
    if [[ -f "$EXAMPLE" ]]; then
      cp "$EXAMPLE" "$ENV_FILE"
      ok "Created $ENV_FILE from $EXAMPLE — fill in real values"
    else
      fail "$ENV_FILE missing (no .example found)"
      MISSING_ENV=true
    fi
  else
    ok "$ENV_FILE exists"
  fi
done

if [[ "$MISSING_ENV" == true ]]; then
  warn "Some .env files could not be created. Check the errors above."
fi

# ─── npm install ──────────────────────────────────────────────────────────────
echo ""
echo "Installing dependencies..."
npm install --silent
ok "npm install complete"

# ─── Tests ────────────────────────────────────────────────────────────────────
echo ""
echo "Running tests..."
if npm test --silent 2>&1 | tail -5; then
  ok "Tests pass"
else
  warn "Some tests failed. This is expected before the database is configured."
fi

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "──────────────────────────────────────────────────────"
echo -e "${BOLD}Next steps:${RESET}"
echo ""
echo "  1. Edit apps/api/.env — set DATABASE_URL and any other secrets"
echo "  2. Start Postgres (Docker Compose or local): docker compose up -d postgres"
echo "  3. Run migrations: npm run db:migrate"
echo "  4. Start dev servers: npm run dev"
echo ""
echo "  To add a new tool:  bash scripts/new-tool.sh <tool-name>"
echo "  To deploy:          bash scripts/deploy.sh"
echo ""
