# Description Guidance

Descriptions are the primary trigger surface for a skill. They should help the agent decide whether to load the skill, not replace the skill body.

## Recommended pattern

```yaml
description: Briefly describe what the skill helps with. Use when [specific triggering conditions, symptoms, or contexts].
```

This keeps two things visible at once:
- capability: what the skill is for
- trigger: when the skill should load

## What to include

- The task or capability the skill covers
- Concrete triggers, symptoms, or decision points
- Searchable keywords such as tools, file types, frameworks, or error text
- Technology-specific context only when the skill itself is technology-specific

## What to avoid

- Full workflow summaries that belong in the body
- Vague labels like "for async testing"
- First-person phrasing
- Overly abstract descriptions with no trigger clues

## Examples

```yaml
# BAD: too vague
description: For async testing

# BAD: describes only workflow
description: Use when executing plans and dispatch subagents with code review between tasks

# BAD: trigger only, omits capability
description: Use when tests have race conditions, timing dependencies, or pass/fail inconsistently

# GOOD: capability + trigger
description: Stabilizes flaky asynchronous tests. Use when tests have race conditions, timing dependencies, or pass/fail inconsistently.

# GOOD: capability + trigger + tech context
description: Handles React Router authentication redirect flows. Use when routing logic must guard signed-in and signed-out states.
```

## Keyword coverage

Add the terms the agent would plausibly search for:
- error messages
- symptoms
- tool names
- framework names
- domain terms
- file types

Examples:
- `Hook timed out`
- `race condition`
- `cleanup`
- `React Router`
- `.docx`

## Length

Keep descriptions compact enough to scan quickly. Under 500 characters is a good default target.
