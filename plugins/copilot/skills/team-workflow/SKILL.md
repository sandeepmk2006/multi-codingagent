---
name: team-workflow
description: Multi-agent team workflow — Claude leads, Antigravity (agy) and GitHub Copilot work as sub-agents in parallel git worktrees. Use ONLY when the user has turned team mode on (/copilot:team-on, or `.multiagent/ACTIVE` exists) or explicitly asks for it. Never start this workflow on your own.
---

# Team workflow

**Activation rule:** this workflow runs only after the user turns it on (`/copilot:team-on` or says "start team mode"). It can start at the beginning or the middle of a project. Outside team mode, work normally and delegate only when asked.

## Roles

| Agent | Call | Best for |
|---|---|---|
| **Claude (lead)** | — | Plan, split, architecture, hard/judgement-heavy parts, verification, merge, final answer |
| **agy** (Gemini Flash / Pro, also Claude 4.6 via Jio plan) | `agy-delegate --tier flash --dir <wt> --yolo --digest "<brief>"` | Bulk generation, scaffolding, test suites, migrations, long-doc/datasheet reading, web research |
| **Copilot** | `copilot-delegate --worktree <name> --digest "<brief>"` | Parallel feature work, second-opinion review (`--review`), quick side tasks |

Pick models per task: cheap/fast model for bulk, stronger model for tricky parts. A reviewer should be a **different model** from the author.

## Loop for each user request

1. **Plan** — break the request into tasks. Mark each: `lead` (do yourself), `agy`, or `copilot`.
   - Delegate only tasks that are **separable** (own files/module) and **big enough** — briefing + verifying costs tokens; small edits: do them yourself.
   - Never give two agents the same files at once.
2. **Board** — write the tasks into `.multiagent/BOARD.md`.
3. **Brief** — every delegated task gets a self-contained brief: goal, files in scope, files NOT to touch, interfaces/contracts it must match, definition of done, test command. Helpers cannot see this conversation.
4. **Dispatch in parallel** — each helper in its own worktree:
   - Copilot: `copilot-delegate --worktree copilot-<slug> --digest "<brief>"`
   - agy: `WT=$(team-worktree agy agy-<slug>)`, then `agy-delegate --dir "$WT" --yolo --digest "<brief>"`. In the brief, name `$WT` as the only folder to work in.
     (`team-worktree` puts the worktree under `~/.multiagent-worktrees/` when the repo is not in agy's trustedWorkspaces — agy otherwise stalls forever on approval prompts headless, even with `--yolo`.)
   - Run long ones with Bash `run_in_background`; do your own `lead` tasks meanwhile.
5. **Verify** — for each finished task: `git -C <wt> status` / `diff --stat`, run build + tests **yourself** in that worktree. Helpers sometimes claim success falsely or stub things to pass — read the diff.
6. **Cross-review** — non-trivial changes get a review by a different agent: `copilot-delegate --review main -d <wt>` for agy's work; `agy-delegate --dir <wt> --digest "review git diff main ..."` for Copilot's. You judge each finding.
7. **Merge** — commit in the worktree, merge `team/<name>` into the working branch, resolve conflicts, run the full test suite, then `git worktree remove` it.
8. **Update the board** and report to the user: who did what, how verified, what's left.

## Lessons from real runs
- Give each helper everything it needs to run its own checks. If its work depends on another agent's branch, merge that branch into its worktree first; otherwise agy can loop trying to build a scratch environment.
- Put "Do NOT create scratch files or directories" in every agy brief.
- agy needs `--yolo` even for read-only reviews (it cannot run commands otherwise); say "do not modify any file" in the brief and check `git status` afterwards.
- Cap agy runs with `--timeout` (8m is plenty for a single file). Copilot was faster and more reliable for reviews in testing.

## Stuck helpers
- No new files in the worktree after several minutes = probably waiting on an approval prompt. Check `git -C <wt> status`, stop the process, fix the cause (trust/permissions), re-dispatch only the missing parts, and keep any finished files.

## Keep the lead lean
- Ingest digests, not raw output. Don't re-read files a helper handled unless verifying.
- If a helper fails twice on a task, take it back and do it yourself.
- If a helper hits a quota/auth error, reroute to the other helper or do it yourself, and tell the user.

## BOARD.md template

```markdown
# Team board
Lead: claude | Agents: claude, agy, copilot

| # | Task | Owner | Model | Worktree/branch | Status | Verified by |
|---|------|-------|-------|-----------------|--------|-------------|

## Notes / decisions
```
Status values: todo, running, review, merged, failed.
