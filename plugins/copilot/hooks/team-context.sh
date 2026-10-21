#!/usr/bin/env bash
# Injects the team-workflow reminder ONLY when the user switched team mode on
# for this project (/copilot:team-on creates .multiagent/ACTIVE). Silent otherwise.
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
[ -f "$root/.multiagent/ACTIVE" ] || exit 0
echo "[team mode ON for this project] Follow the copilot:team-workflow skill: Claude leads (plan, hard parts, verify, merge); delegate separable work to agy (agy-delegate) and Copilot (copilot-delegate), each in its own worktree; track tasks in .multiagent/BOARD.md; cross-review before merging; never trust a self-reported 'done'. Turn off with /copilot:team-off."
