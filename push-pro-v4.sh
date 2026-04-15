#!/usr/bin/env bash
# =============================================================================
# PRO PUSH v4.0 — Ultra Pro Edition
# =============================================================================
set -euo pipefail

echo "🚀 PRO PUSH v4.0 — EvolveSpintronics"

git fetch origin --prune --tags --quiet

CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current branch: $CURRENT_BRANCH"

# Smart feature branch creation
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
  if [ -n "${1:-}" ]; then
    FEAT=$(echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | cut -c1-50)
  else
    FEAT="update-$(date +%Y%m%d-%H%M)"
  fi
  echo "⚠️  On main → creating feature branch"
  git checkout -b "feature/$FEAT"
fi

# Rebase
echo "🔄 Rebasing onto origin/main..."
git rebase origin/main --update-refs --autostash || { echo "❌ Rebase conflict!"; exit 1; }

# Lint
if command -v ruff >/dev/null 2>&1; then
  echo "🧹 Running ruff lint & format..."
  ruff check --fix . --quiet || true
  ruff format . --quiet || true
fi

# Status
echo -e "\n📊 Status:"
git status --short

# Staging
read -r -p "Stage ALL changes? (y/n/select) [y]: " s
s=${s:-y}
case "$s" in
  y|Y) git add --all ;;
  s|S|select) git add -p ;;
  *) echo "❌ Nothing staged."; exit 0 ;;
esac

if git diff --cached --quiet; then
  echo "❌ No changes to commit."
  exit 0
fi

# Commit message
if [ -n "${1:-}" ]; then
  MSG="$1"
else
  echo "Conventional commits: feat, fix, refactor, docs, chore, perf..."
  read -r -p "Commit message: " MSG
fi

git commit -m "$MSG"

# Push
echo "📤 Pushing to GitHub..."
git push --force-with-lease --set-upstream origin HEAD

# Create PR
read -r -p "Create Pull Request? (y/n) [y]: " p
p=${p:-y}
if [[ $p == y || $p == Y ]]; then
  gh pr create --title "$MSG" \
    --body "Advanced changes via pro push v4.0" \
    --assignee @me \
    --label enhancement || true
  gh pr view --web 2>/dev/null || true
fi

echo -e "\n🎉 DONE! Branch pushed successfully."
echo "Repo: https://github.com/NullLabTests/EvolveSpintronics"
