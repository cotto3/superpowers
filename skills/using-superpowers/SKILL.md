---
name: using-superpowers
description: Use at conversation start to establish skill invocation rules
---

## The Rule

**Invoke relevant skills BEFORE any response or action — including clarifying questions.** Even a 1% chance a skill applies means invoke it. If it turns out to be wrong, you don't need to follow it.

Use the `Skill` tool to invoke skills. Never use the Read tool on skill files.

## Priority

1. **Process skills first** (brainstorming, debugging) — these determine HOW to approach the task
2. **Implementation skills second** (frontend-design, etc.) — these guide execution

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.
**Flexible** (patterns): Adapt principles to context. The skill itself tells you which.

## Don't Rationalize Skipping

If you catch yourself thinking "this is too simple for a skill" or "let me just do this one thing first" — stop. Check for skills first. User instructions say WHAT, not HOW. "Add X" doesn't mean skip workflows.
