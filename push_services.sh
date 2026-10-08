#!/usr/bin/env bash
#
# push_services.sh
# Adds, commits and pushes every ek-* service whose remote URL is set below.
# Services with an empty remote URL are skipped (no active work there).
# Compatible with macOS's default bash 3.2.
#
# Usage: run from the folder that contains the ek-* directories,
#        or set BASE_DIR=/path/to/parent ./push_services.sh

set -o pipefail

BASE_DIR="${BASE_DIR:-$(pwd)}"
SRC_SUBDIR="src"
DEFAULT_BRANCH="main"

# ---------------------------------------------------------------------------
# Remote URLs: format is  "service|remote-url"
# Fill in the ones you are working on; leave the part after | empty to skip.
# Use HTTPS URLs (username/password auth does not apply to SSH remotes).
# ---------------------------------------------------------------------------
SERVICES=(
  "ek-core|https://github.com/khakin084/ek-core.git"
  "ek-auth|https://github.com/khakin084/ek-auth.git"
  "ek-config|https://github.com/khakin084/ek-config.git"
  "ek-approvals|https://github.com/khakin084/ek-approvals.git"
  "ek-trades|https://github.com/khakin084/ek-trades.git"
  "ek-itemmaster|https://github.com/khakin084/ek-itemmaster.git"
  "ek-inventory|https://github.com/khakin084/ek-inventory.git"
  "ek-production|"
  "ek-logistics|https://github.com/khakin084/ek-logistics.git"
  "ek-accounts|https://github.com/khakin084/ek-accounts.git"
  "ek-reporting|"
  "ek-projects|"
  "ek-hr|"
  "ek-assets|"
)

# ---------------------------------------------------------------------------
# Work out which services are active before prompting for anything
# ---------------------------------------------------------------------------
ACTIVE_LIST=""
for entry in "${SERVICES[@]}"; do
  svc="${entry%%|*}"
  remote="${entry#*|}"
  [ -n "$remote" ] && ACTIVE_LIST="$ACTIVE_LIST $svc"
done

if [ -z "$ACTIVE_LIST" ]; then
  echo "No remote URLs are set. Nothing to do."
  exit 0
fi

echo "Services with remotes:$ACTIVE_LIST"
echo

# ---------------------------------------------------------------------------
# Prompts: commit message, then credentials
# ---------------------------------------------------------------------------
COMMIT_MSG=""
while [ -z "$COMMIT_MSG" ]; do
  read -r -p "Commit message: " COMMIT_MSG
done

read -r -p "Git username: " GIT_USERNAME
read -r -s -p "Git password / token: " GIT_PASSWORD
echo
echo

# Feed credentials to git via a temporary askpass helper so the password
# never ends up in a remote URL, the process list, or .git/config.
ASKPASS_FILE="$(mktemp)"
cat > "$ASKPASS_FILE" <<'EOF'
#!/bin/sh
case "$1" in
  Username*) printf '%s\n' "$GIT_USERNAME" ;;
  Password*) printf '%s\n' "$GIT_PASSWORD" ;;
esac
EOF
chmod 700 "$ASKPASS_FILE"

cleanup() {
  rm -f "$ASKPASS_FILE"
  unset GIT_PASSWORD
}
trap cleanup EXIT

export GIT_USERNAME GIT_PASSWORD
export GIT_ASKPASS="$ASKPASS_FILE"
export GIT_TERMINAL_PROMPT=0

PUSHED=""
FAILED=""
SKIPPED=""

# ---------------------------------------------------------------------------
# Process each service
# ---------------------------------------------------------------------------
for entry in "${SERVICES[@]}"; do
  svc="${entry%%|*}"
  remote="${entry#*|}"
  dir="$BASE_DIR/$svc/$SRC_SUBDIR"

  if [ -z "$remote" ]; then
    SKIPPED="$SKIPPED
  - $svc (no remote)"
    continue
  fi

  echo "=== $svc ==="

  if [ ! -d "$dir" ]; then
    echo "  Directory $dir not found, skipping."
    SKIPPED="$SKIPPED
  - $svc (no directory)"
    continue
  fi

  (
    cd "$dir" || exit 1

    # Initialise repo if needed
    if [ ! -d .git ]; then
      echo "  Initialising git repository..."
      git init -q || exit 1
      git checkout -q -b "$DEFAULT_BRANCH" 2>/dev/null
    fi

    # Make sure origin points at the configured remote
    if git remote get-url origin >/dev/null 2>&1; then
      current="$(git remote get-url origin)"
      if [ "$current" != "$remote" ]; then
        echo "  Updating origin: $current -> $remote"
        git remote set-url origin "$remote" || exit 1
      fi
    else
      git remote add origin "$remote" || exit 1
    fi

    git add . || exit 1

    if git diff --cached --quiet; then
      echo "  Nothing new to commit."
      # No commits at all means nothing to push either
      git rev-parse --verify HEAD >/dev/null 2>&1 || exit 2
    else
      git commit -q -m "$COMMIT_MSG" || exit 1
      echo "  Committed."
    fi

    branch="$(git symbolic-ref --short HEAD 2>/dev/null || echo "$DEFAULT_BRANCH")"
    echo "  Pushing $branch to origin..."
    git -c credential.helper= push -u origin "$branch" || exit 1
  )
  status=$?

  case $status in
    0) PUSHED="$PUSHED $svc"; echo "  Done." ;;
    2) SKIPPED="$SKIPPED
  - $svc (empty repo)" ;;
    *) FAILED="$FAILED $svc"; echo "  FAILED." ;;
  esac
  echo
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo "================ Summary ================"
echo "Pushed :${PUSHED:- none}"
echo "Skipped:${SKIPPED:- none}"
echo "Failed :${FAILED:- none}"

[ -z "$FAILED" ]
