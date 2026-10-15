# Auto-Start Instructions for Claude Code

You are working in a DevCloud environment connected to GitHub. When this session starts (or after `/clear`), you MUST automatically perform the following bootstrap sequence without waiting for user instructions:

1. **Context Sync:** Read the `PROJECT_STATUS.md` file in the root directory to understand the current implementation status, bugs, and next actions.
2. **Git Check:** Run `git status` and `git pull` to ensure you are up to date with the remote repository.
3. **Action Execution:** Immediately analyze the tasks listed in "3. 바로 진행해야 할 다음 개발 일정 (Next Actions)" of `PROJECT_STATUS.md` and prepare to execute them.

> Note: The `SessionStart` hook (`.claude/hooks/session-start.sh`) already runs `git pull` and injects
> `git status` + `PROJECT_STATUS.md` into your context. If that output is present, treat steps 1–2 as done
> and go straight to step 3. If the hook reported a pull failure or conflict, resolve it first.

# Session Wrap-Up (before ending work)

Whenever you finish a task or the user signals the session is ending:

1. **Update `PROJECT_STATUS.md`:** move finished items to section 1, record new bugs in section 2,
   rewrite section 3 with the concrete next actions, and set `*최종 업데이트: YYYY-MM-DD*` to today.
2. **Commit** with a meaningful message describing the work (don't leave it to the auto-commit).

The `SessionEnd` hook (`.claude/hooks/session-end.sh`) automatically commits any remaining changes
and runs `git push` when the session ends (exit, `/clear`, `/resume`). It is a safety net only —
it cannot update `PROJECT_STATUS.md` for you, so step 1 above is still your responsibility.
