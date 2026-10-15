#!/usr/bin/env bash
# SessionEnd hook: auto-commit remaining changes and push to the remote.
# Output is not shown to Claude, so results are logged to .claude/hooks/sync.log (gitignored).

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
export GIT_TERMINAL_PROMPT=0   # never hang waiting for credentials

LOG=".claude/hooks/sync.log"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; }

# Read the exit reason from the hook's JSON input (no jq dependency).
input="$(cat 2>/dev/null)"
reason="$(printf '%s' "$input" | sed -n 's/.*"reason"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
reason="${reason:-unknown}"

branch="$(git rev-parse --abbrev-ref HEAD)"
if [ "$branch" = "HEAD" ]; then
  log "detached HEAD - skipping auto-sync"
  exit 0
fi

# 1) Commit any uncommitted changes.
if [ -n "$(git status --porcelain)" ]; then
  today="$(date '+%Y-%m-%d')"
  if [ -f PROJECT_STATUS.md ]; then
    sed -i "s/^\*최종 업데이트: .*\*$/*최종 업데이트: ${today}*/" PROJECT_STATUS.md
  fi
  git add -A
  if git commit -q -m "chore: auto-sync on session end (${reason}, $(date '+%Y-%m-%d %H:%M'))" >> "$LOG" 2>&1; then
    log "committed changes on $branch"
  else
    log "commit failed"
    exit 0
  fi
fi

# 2) Push if there is anything ahead of the remote.
if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  ahead="$(git rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)"
  [ "$ahead" -eq 0 ] && { log "nothing to push ($reason)"; exit 0; }
  git pull --rebase --autostash -q >> "$LOG" 2>&1 || log "WARNING: pull --rebase failed; attempting push anyway"
  if git push -q >> "$LOG" 2>&1; then
    log "pushed $ahead commit(s) to origin/$branch ($reason)"
  else
    log "ERROR: push failed - run 'git push' manually"
  fi
else
  if git push -q -u origin "$branch" >> "$LOG" 2>&1; then
    log "pushed new branch $branch to origin ($reason)"
  else
    log "ERROR: push of new branch $branch failed"
  fi
fi

exit 0
