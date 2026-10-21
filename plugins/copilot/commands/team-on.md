---
description: Turn ON the multi-agent team workflow for this project (Claude leads, agy + Copilot as sub-agents).
argument-hint: "[agents: claude,agy,copilot] [lead: claude]"
---
The user is switching team mode ON for this project from now on. Arguments: $ARGUMENTS

1. Ensure this is a git repo (if not, ask before `git init`). Make sure there is at least one commit (worktrees need one).
2. Create `.multiagent/ACTIVE` containing the agents and lead (default agents: claude,agy,copilot; lead: claude).
3. Create `.multiagent/BOARD.md` if missing, from the template in the `team-workflow` skill.
4. Add `.multiagent/worktrees/` to `.gitignore`.
5. Check helpers respond: `copilot-delegate --help >/dev/null` and `command -v agy-delegate`. Report which are available.
6. Load the `copilot:team-workflow` skill and follow it for all remaining work in this project until /copilot:team-off.
Confirm to the user in 2–3 lines.
