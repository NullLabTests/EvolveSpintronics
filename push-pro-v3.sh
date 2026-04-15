#!/usr/bin/env bash
# PRO PUSH v3.1 — Final clean version
set -euo pipefail

echo "🚀 PRO PUSH v3.1 starting..."

git fetch origin --prune --tags --quiet
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 On branch: $CURRENT_BRANCH"

# Auto feature branch if on main
if [[ "$CURRENT_BRANCH" == "main" ]]; then
  echo "⚠️ On main → new feature branch"
  read -r -p "Feature name: " feat
  git checkout -b "feature/${feat:-$(date +%Y%m%d)}"
fi

git rebase origin/main --update-refs --autostash || { echo "❌ Rebase conflict!"; exit 1; }

if command -v ruff >/dev/null 2>&1; then ruff check --fix .; fi

git status --short

read -r -p "Stage ALL? (y/n) [y]: " s; s=${s:-y}
[[ $s == y ]] && git add --all || { echo "Nothing staged"; exit 0; }

[[ -n "${1:-}" ]] && MSG="$1" || read -r -p "Commit message: " MSG
git commit -m "$MSG"

git push --force-with-lease --set-upstream origin HEAD

read -r -p "Create PR? (y/n) [y]: " p; p=${p:-y}
if [[ $p == y ]]; then
  gh pr create --title "$MSG" --body "Pro push via v3.1" --assignee @me --label enhancement || true
  gh pr view --web 2>/dev/null || true
fi

echo "🎉 DONE!"
