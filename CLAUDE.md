# CLAUDE.md

This is a fork of [obra/superpowers](https://github.com/obra/superpowers) with GitHub Issues integration. Used by a solo iOS/Swift developer (Christian Otto) for the [Slow Weave](https://github.com/cotto3/goaltracker) project and general development.

## Skill Inventory

### Workflow chain (customized)

```
brainstorming → writing-plans → subagent-driven-development → finishing-a-development-branch
```

| Skill | Purpose | Customized? |
|-------|---------|-------------|
| `using-superpowers` | Session-start meta-skill: enforce "check for skills before acting" | Yes (slimmed ~80%) |
| `brainstorming` | Collaborative design before implementation. Produces a design doc, then invokes `writing-plans` | No |
| `writing-plans` | Turn design into bite-sized TDD plan, create GitHub Issues, hand off to implementation | Yes (unified handoff) |
| `subagent-driven-development` | Implement GitHub Issues: assess complexity, dispatch 1+ implementer subagents, two-stage review | Yes (rewritten) |
| `finishing-a-development-branch` | Verify tests → present merge/PR/keep/discard options → clean up worktree | Yes (added `Closes #N`) |

### Supporting skills (unmodified from upstream)

| Skill | Purpose |
|-------|---------|
| `using-git-worktrees` | Create isolated workspace before implementation |
| `test-driven-development` | Red-green-refactor discipline for implementer subagents |
| `verification-before-completion` | Evidence before claims — run commands before asserting success |
| `requesting-code-review` | Dispatch code reviewer subagent with diff context |
| `receiving-code-review` | Handle reviewer feedback |
| `dispatching-parallel-agents` | Parallelize independent problems (debugging, not implementation) |
| `executing-plans` | Upstream plan-file batch execution (alternative to `subagent-driven-development`, does not use GitHub Issues) |
| `systematic-debugging` | Structured debugging methodology |
| `writing-skills` | How to write new skills |

### Prompt templates (in `subagent-driven-development/`)

| Template | Used by | Purpose |
|----------|---------|---------|
| `implementer-from-issue-prompt.md` | Step 2 (Implement) | Issue-aware implementer subagent prompt with acceptance criteria, self-review checklist |
| `spec-reviewer-prompt.md` | Step 3 (Review) | Verify implementation matches issue's acceptance criteria |
| `code-quality-reviewer-prompt.md` | Step 3 (Review) | Code quality review using `requesting-code-review` template |

## Success Criteria

**`writing-plans` is effective when:**
- Issues are self-contained (implementer subagent doesn't need to read the plan file)
- Each issue has clear acceptance criteria
- Issues are scoped by functionality, not by file count or subagent capacity
- Shared label ties all issues from one plan together

**`subagent-driven-development` is effective when:**
- Complexity assessment matches reality (simple issues don't get over-split, complex issues don't overwhelm a single subagent)
- Implementer subagents don't need to ask clarifying questions (context was sufficient)
- Spec reviewer catches missing acceptance criteria before code quality review
- Fix subagents resolve issues without re-introducing regressions
- All commits reference issue numbers

**`finishing-a-development-branch` is effective when:**
- PR body includes `Closes #N` for every implemented issue
- Tests are verified before presenting options
- Worktree cleanup matches the chosen option

**`using-superpowers` is effective when:**
- Skills are invoked before acting, without consuming excessive context (~250 tokens)

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
- `skills/subagent-driven-development/spec-reviewer-prompt.md` — adapted for GitHub issue numbers and acceptance criteria
- `skills/subagent-driven-development/code-quality-reviewer-prompt.md` — adapted for GitHub issue references
- `skills/finishing-a-development-branch/SKILL.md` — Option 2 (Create PR) now includes `Closes #N` for each implemented issue
- `skills/using-superpowers/SKILL.md` — slimmed from ~1,200 to ~250 tokens; removed redundant rationalization table, unrenderable Graphviz diagram, and triple-repeated core message

## Edit Workflow

1. Edit skill files in this repo (e.g., `skills/writing-plans/SKILL.md`)
2. Bump `version` in **both** `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` (use semver patch bump, e.g., `4.3.3` → `4.3.4`)
3. Commit and push to origin (`cotto3/superpowers`)
4. In Claude Code, run `/plugin update superpowers@superpowers-dev` to pull the new version

## Pulling Upstream Updates

```bash
git fetch upstream
git merge upstream/main
# Resolve any conflicts with GitHub integration additions
git push
```
