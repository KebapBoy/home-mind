#!/bin/bash
# Home Mind Diff Script
# Shows what an update would change. Read-only: never pulls, merges or deploys,
# so it works with uncommitted changes and on any branch.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "Home Mind Diff"
echo "=============="
echo ""

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Branch: $CURRENT_BRANCH"

# Report local changes (informational only)
LOCAL_CHANGES=$(git status --short)
if [ -n "$LOCAL_CHANGES" ]; then
    echo ""
    echo "Uncommitted changes:"
    echo "$LOCAL_CHANGES"
fi

# Fetch latest from origin
echo ""
echo "Checking for updates..."
git fetch origin main --quiet

LOCAL_HEAD=$(git rev-parse HEAD)
REMOTE_HEAD=$(git rev-parse origin/main)

if [ "$LOCAL_HEAD" = "$REMOTE_HEAD" ]; then
    echo "Already up to date."
    exit 0
fi

COMMIT_COUNT=$(git rev-list --count "$LOCAL_HEAD".."$REMOTE_HEAD")
AHEAD_COUNT=$(git rev-list --count "$REMOTE_HEAD".."$LOCAL_HEAD")

if [ "$COMMIT_COUNT" -eq 0 ]; then
    echo "No incoming commits ($AHEAD_COUNT local commit(s) not on origin/main)."
    exit 0
fi

echo ""
echo "Incoming commits ($COMMIT_COUNT):"
echo "----------------------------------------------"
git log --oneline --no-decorate "$LOCAL_HEAD".."$REMOTE_HEAD"
echo "----------------------------------------------"

if [ "$AHEAD_COUNT" -gt 0 ]; then
    echo ""
    echo "Note: $AHEAD_COUNT local commit(s) not on origin/main; a fast-forward update would not apply."
fi

# Diff from the merge base so local commits aren't shown as reverted
BASE=$(git merge-base "$LOCAL_HEAD" "$REMOTE_HEAD")

echo ""
echo "Files changed:"
git diff --stat "$BASE" "$REMOTE_HEAD"

# Warn where incoming changes touch files with uncommitted edits
if [ -n "$LOCAL_CHANGES" ]; then
    OVERLAP=$(comm -12 \
        <(git diff --name-only "$BASE" "$REMOTE_HEAD" | sort) \
        <(git diff --name-only HEAD | sort))
    if [ -n "$OVERLAP" ]; then
        echo ""
        echo "WARNING: incoming changes touch files you have modified locally:"
        echo "$OVERLAP" | sed 's/^/  /'
    fi
fi

echo ""
git diff "$BASE" "$REMOTE_HEAD"
