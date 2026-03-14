#!/usr/bin/env zsh
#
# publish.sh — Bump version tag and push to GitHub.
# Usage: ./scripts/publish.sh [patch|minor|major]
#

set -euo pipefail

BUMP=${1:-patch}
REPO_ROOT=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Ensure working tree is clean.
if [[ -n $(git status --porcelain) ]]; then
  echo "❌  Working tree is dirty. Commit or stash changes first."
  exit 1
fi

# Ensure we're on main and up to date.
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" != "main" ]]; then
  echo "❌  Must be on 'main' branch (currently on '$BRANCH')."
  exit 1
fi

git pull --ff-only origin main

# Get the latest semver tag (default to v0.0.0 if none).
LATEST=$(git tag --list 'v*.*.*' --sort=-version:refname | head -n1)
LATEST=${LATEST:-v0.0.0}

# Strip leading 'v' and split into parts.
VERSION=${LATEST#v}
MAJOR=${VERSION%%.*}
REST=${VERSION#*.}
MINOR=${REST%%.*}
PATCH=${REST#*.}

case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
  *)
    echo "❌  Unknown bump type '$BUMP'. Use: patch | minor | major"
    exit 1
    ;;
esac

NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}"

echo "📦  Current version : $LATEST"
echo "🚀  New version     : $NEW_TAG  ($BUMP bump)"
echo ""
read -q "CONFIRM?Proceed? [y/N] " || { echo "\nAborted."; exit 0; }
echo ""

git tag "$NEW_TAG"
git push origin main --tags

echo ""
echo "✅  Published $NEW_TAG — https://github.com/dxos/zsh/releases/tag/$NEW_TAG"
