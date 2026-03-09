---
name: requesting-code-review
description: Use when an implementation batch or GitHub issue is complete and you need code-quality review before continuing or merging
---

# Requesting Code Review

Dispatch superpowers:code-reviewer subagent to catch issues before they cascade.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After implementation is complete for an issue in subagent-driven development, once spec compliance review has already passed
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code-reviewer subagent:**

Use Task tool with superpowers:code-reviewer type, fill template at `code-reviewer.md`

**Placeholders:**
- `{WHAT_WAS_IMPLEMENTED}` - What you just built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit
- `{DESCRIPTION}` - Brief summary

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Issue #142 implementation is complete and spec compliance review passed]

You: Let me request code quality review before I move to the next issue.

BASE_SHA=$(git merge-base HEAD origin/main)
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch superpowers:code-reviewer subagent]
  WHAT_WAS_IMPLEMENTED: Offline caching and sync queue support for Issue #142
  PLAN_OR_REQUIREMENTS: GitHub Issue #142 acceptance criteria plus the approved spec-review result
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: Finished Issue #142 after spec compliance review passed

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Sync queue retry backoff is duplicated in two files
    Minor: One helper name is vague
  Assessment: Fix important issue before continuing

You: [Fix retry backoff duplication]
[Re-request code review]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Review once per issue, after implementation is complete and spec compliance has already passed
- Catch code quality issues before moving to the next issue
- Fix reviewer findings, then re-review before continuing

**Executing Plans:**
- Review after each batch (3 tasks)
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: requesting-code-review/code-reviewer.md
