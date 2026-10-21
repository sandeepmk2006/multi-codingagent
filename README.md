# multi-codingagent

**Use all your AI coding agents at once — one leader, the rest as sub-agents.**

I pay for three coding agents — **Claude Code** (Pro), **Antigravity / agy** (Pro via Jio) and **GitHub Copilot** (student plan) — but normally only one works at a time. This project makes them work as a team:

- **Pick a leader** (Claude Code by default). The leader plans, splits the work, does the hard parts itself, and verifies everything.
- **Other agents are sub-agents.** Separable work (scaffolding, tests, features in their own files, research, reviews) goes to agy and Copilot, each running in parallel in its **own git worktree**, on its own subscription.
- **Cross-review.** A different model reviews each change before it is merged — different models catch different bugs.

### Goals
| Goal | How |
|---|---|
| **Less load on one agent** | Bulk work runs on agy/Copilot quota; the leader only plans and verifies, reading short digests instead of whole files. |
| **Faster** | Independent tasks run at the same time in separate worktrees. |
| **Better output** | Leader verifies by running build/tests itself (never trusts a self-reported "done") + cross-model review. |

### Honest limits
- Agents don't share a live brain. They communicate through written briefs, the code, git, and a shared task board (`.multiagent/BOARD.md`).
- Speed-up only happens when work is truly separable. Small tasks are faster done by the leader alone.
- Each agent is driven through its **official CLI** (`claude`, `agy`, `copilot`), so each uses its own subscription legitimately — no token extraction.

---

## What's here

`plugins/copilot` — a Claude Code plugin that adds:

- **`copilot-delegate`** — runs GitHub Copilot CLI headless as a sub-agent: model choice, read-only or write mode, isolated worktree per task, review mode, compact digests, failure detection.
- **Opt-in team workflow** — the multi-agent workflow runs **only when you switch it on** for a project, at the start or midway.

Works alongside the antigravity plugin (`agy-delegate`) for the Antigravity side.

### Commands

| Command | What it does |
|---|---|
| `/copilot:team-on` | Turn team mode ON for this project (Claude leads, agy + Copilot as sub-agents) |
| `/copilot:team-off` | Turn it off — back to normal single-agent work |
| `/copilot:team-status` | Task board, open worktrees, progress |
| `/copilot:delegate <task>` | Send one task to Copilot (no team mode needed) |
| `/copilot:review [base]` | Copilot reviews the current diff; Claude judges each finding |

### `copilot-delegate` CLI

```bash
copilot-delegate "explain src/auth.ts"                      # read-only question
copilot-delegate --worktree login --digest "add login page"  # edits on branch team/login
copilot-delegate --review main                               # review git diff main
copilot-delegate --model <name> --effort high "..."          # pick model / reasoning effort
```
Exit codes: `0` ok · `1` usage · `2` copilot failed · `3` empty · `4` write task changed nothing · `12` timeout

## Install

Requirements: [Claude Code](https://claude.com/claude-code), [GitHub Copilot CLI](https://github.com/github/copilot-cli) (`copilot login`), git, bash (Git Bash on Windows). Optional: Antigravity CLI (`agy`) + the antigravity plugin.

```bash
claude plugin marketplace add sandeepmk2006/multi-codingagent
claude plugin install copilot@multi-codingagent
```
Restart Claude Code, open a git repo (with at least one commit) and run `/copilot:team-on`.

## How a team-mode request flows

1. **Plan** — leader splits the request into tasks: `lead` / `agy` / `copilot`.
2. **Board** — tasks recorded in `.multiagent/BOARD.md`.
3. **Brief** — each sub-agent gets a self-contained brief (goal, files in/out of scope, done-criteria, test command).
4. **Dispatch** — sub-agents run in parallel, each in `.multiagent/worktrees/<name>` on branch `team/<name>`.
5. **Verify** — leader inspects the diff and runs build/tests itself.
6. **Cross-review** — a different agent reviews; leader judges findings.
7. **Merge** — merge, full test run, remove worktree, update board.

## Notes (Windows)
- Prompts are sent to Copilot via stdin: a newline inside `copilot -p` on Windows silently drops the permission flags after it.
- Write mode passes `--allow-all-paths` because folders outside Copilot's `trustedFolders` deny every write headless.

## Roadmap
- [ ] Choose any agent as leader (agy or Copilot leading), not only Claude
- [ ] MCP server version so any MCP-capable agent can orchestrate
- [ ] Usage/quota tracking per agent to route work to whoever has budget left
- [ ] Optional desktop/TUI dashboard

## License
MIT
