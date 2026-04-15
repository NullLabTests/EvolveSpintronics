#!/usr/bin/env bash
# =============================================================================
# PRO PUSH v2.1 — SUPER CLEAN for EvolveSpintronics
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

echo -e "${BLUE}🚀 PRO PUSH v2.1${NC}"
echo -e "Time: $(date '+%Y-%m-%d %H:%M:%S %Z')\n"

# Sanity
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo -e "${RED}❌ Not in a git repo!${NC}"
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo -e "${RED}❌ gh (GitHub CLI) not found${NC}"
  exit 1
fi

gh auth status >/dev/null 2>&1 || { echo -e "${RED}❌ Run: gh auth login${NC}"; exit 1; }

# Fetch
git fetch origin --prune --tags --quiet

CURRENT_BRANCH=$(git branch --show-current)
DEFAULT_BRANCH="main"

echo -e "${YELLOW}📍 On branch: $CURRENT_BRANCH${NC}"

# Rebase (you are already on feature branch)
echo -e "${BLUE}🔄 Rebasing onto origin/main...${NC}"
git rebase origin/main --update-refs --autostash || { echo -e "${RED}Rebase conflict — fix manually${NC}"; exit 1; }

# Lint
if command -v ruff >/dev/null 2>&1; then
  echo -e "${BLUE}🔍 Running ruff...${NC}"
  ruff check --fix .
fi

# Status
echo -e "\n${BLUE}📊 Status:${NC}"
git status --short

echo ""
read -r -p "Stage ALL changes? (y/n/select) [y]: " STAGE
STAGE=${STAGE:-y}

case "$STAGE" in
  y|Y) git add --all; echo -e "${GREEN}✅ Staged${NC}" ;;
  s|S|select) git add -p ;;
  *) echo -e "${RED}❌ Nothing staged${NC}"; exit 0 ;;
esac

if git diff --cached --quiet; then
  echo -e "${RED}❌ No changes${NC}"
  exit 0
fi

# Commit
if [ -n "${1:-}" ]; then
  MSG="$1"
else
  read -r -p "Commit message: " MSG
fi
git commit -m "$MSG"

# Push
echo -e "${BLUE}📤 Pushing...${NC}"
git push --force-with-lease --set-upstream origin HEAD

# PR
read -r -p "Create PR? (y/n) [y]: " PR
PR=${PR:-y}
if [[ "$PR" == y || "$PR" == Y ]]; then
  gh pr create --title "$MSG" --body "Automated via push-pro-v2.1" --assignee @me --label enhancement || true
  gh pr view --web 2>/dev/null || true
fi

echo -e "\n${GREEN}🎉 Done!${NC}"
