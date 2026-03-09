# CLAUDE.md

This is a fork of [obra/superpowers](https://github.com/obra/superpowers) with GitHub integration additions.

## Edit Workflow

1. Edit skill files in this repo (e.g., `skills/writing-plans/SKILL.md`)
2. Bump `version` in **both** `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` (use semver patch bump, e.g., `4.3.2` → `4.3.3`)
3. Commit and push to origin (`cotto3/superpowers`)
4. In Claude Code, run `/plugin update superpowers@superpowers-dev` to pull the new version

## Pulling Upstream Updates

```bash
git fetch upstream
git merge upstream/main
# Resolve any conflicts with GitHub integration additions
git push
```

## Design

**Unified workflow:** plan → GitHub Issues (scoped by functionality) → adaptive subagent implementation → two-stage review → PR

**Key design decisions:**
- **Issues scoped by functionality, not subagent capacity.** `writing-plans` defines *what* to build. `subagent-driven-development` decides *how many subagents* each issue needs.
- **Adaptive subagent count.** Simple issues get 1 subagent. Complex issues (spanning multiple layers) get broken into sequential sub-tasks, each with a fresh subagent. The complexity assessment happens at implementation time, not planning time.
- **Two-stage review runs once per issue** (not per sub-task). Spec compliance first, then code quality.

## What Was Customized

Files modified from upstream:

- `skills/writing-plans/SKILL.md` — replaced 3-option execution handoff with single flow: plan → create GitHub issues → implement. Issue sizing is purely functionality-based; implementation decides subagent count.
- `skills/subagent-driven-development/SKILL.md` — removed upstream plan-file-based mode. Unified around GitHub Issues with adaptive subagent count: reads each issue, assesses complexity, dispatches 1 or multiple subagents accordingly. Two-stage review per issue, commits reference issue numbers, PR body includes `Closes #N`.
- `skills/subagent-driven-development/implementer-from-issue-prompt.md` — new prompt template for issue-aware implementer subagents (replaces `implementer-prompt.md` usage)
- `skills/finishing-a-development-branch/SKILL.md` — Option 2 (Create PR) now includes `Closes #N` for each implemented issue
- `skills/using-superpowers/SKILL.md` — slimmed from ~1,200 to ~250 tokens; removed redundant rationalization table, unrenderable Graphviz diagram, and triple-repeated core message
