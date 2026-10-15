#!/usr/bin/env bash
# SessionStart hook: sync with remote and inject project context.
# Everything printed to stdout is added to Claude's context.

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" || exit 0
export GIT_TERMINAL_PROMPT=0   # never hang waiting for credentials

echo "=== [auto] SessionStart bootstrap ==="

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch="$(git rev-parse --abbrev-ref HEAD)"
  echo "--- git pull (branch: $branch) ---"
  if pull_out="$(git pull --rebase --autostash 2>&1)"; then
    echo "$pull_out"
  else
    echo "$pull_out"
    echo "WARNING: git pull failed. Resolve this before starting work."
  fi
  echo
  echo "--- git status ---"
  git status -sb
  echo
  echo "--- recent commits ---"
  git log --oneline -n 5
else
  echo "WARNING: not a git repository."
fi

echo
if [ -f PROJECT_STATUS.md ]; then
  echo "--- PROJECT_STATUS.md ---"
  cat PROJECT_STATUS.md
  echo
  echo "Bootstrap steps 1-2 are done. Proceed with step 3 in CLAUDE.md (Next Actions)."
else
  echo "WARNING: PROJECT_STATUS.md not found in project root."
fi

exit 0
