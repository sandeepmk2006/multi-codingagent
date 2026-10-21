---
description: Delegate a well-scoped subtask to GitHub Copilot CLI, then verify it yourself.
argument-hint: "[--model <m>] [--worktree <name>] <task>"
---
Delegate this task to GitHub Copilot via the plugin wrapper:

Task: $ARGUMENTS

1. Write a self-contained brief: goal, files in scope, files NOT to touch, definition of done, how to test.
2. Run synchronously: `copilot-delegate --digest [--model <m>] [--worktree <name> | --write] "<brief>"`
   - Read-only questions/analysis: no `--write`.
   - Edits: prefer `--worktree <name>` so Copilot works on its own branch `team/<name>`.
   - Long task: run it with Bash `run_in_background` and keep working.
3. Ingest only the digest. Do not re-read files Copilot handled unless verifying.
4. Verify: `git -C <worktree> diff --stat`, then run the build/tests yourself. Never trust a self-reported "done".
5. Report: what was delegated, which model, how you verified, result.
