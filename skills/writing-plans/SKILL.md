---
name: writing-plans
description: Turns approved requirements into a bite-sized implementation plan and GitHub issues. Use after brainstorming or whenever a multi-step change needs planned execution before code is touched.
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** Planning can happen in the current workspace. Create or switch to a dedicated worktree before implementation begins.

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For the implementing agent:** REQUIRED SUB-SKILL: Use ottopowers-gh:subagent-driven-development to implement this plan via GitHub Issues.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Reference relevant skills by name
- DRY, YAGNI, TDD, frequent commits

## Execution Handoff

After saving the plan, create GitHub Issues and begin implementation.

**"Plan complete and saved to `docs/plans/<filename>.md`. Creating GitHub issues now."**

This is the default workflow for the customized GitHub Issues path. `executing-plans` remains available as the upstream plan-file alternative when the user explicitly wants a separate-session execution flow.

### Step 1: Create GitHub Issues

Map plan tasks to GitHub issues. **Scope issues by functionality**, not by subagent capacity. The implementation skill will decide how many subagents each issue needs — your job is to define *what* to build, not *how* to subdivide it for agents.

**Issue scoping guidance:**

Each issue should represent a coherent unit of functionality that makes sense on its own.

*When to keep tasks in one issue:*
- They contribute to the same user-facing feature or behavior
- They're tightly coupled and would be awkward to review separately
- Splitting would create merge conflicts between subagents
- Small changes should naturally result in just one issue — that's the normal case, not a sign you need to split further

*When to split into separate issues:*
- Tasks represent genuinely distinct features or concerns (e.g., "offline caching" vs. "push notifications")
- Issues with dependencies are fine — note the order (e.g., "Depends on #142") so they execute sequentially

*General principles:*
- For compiled projects (iOS/Xcode, Rust, Java, etc.) where builds take meaningful time, prefer fewer issues
- Each issue must be self-contained: include everything needed to implement it without reading the plan file
- Don't pre-optimize issue size for subagent context limits — the implementation skill handles that

**Creating issues:**
- Use `gh issue create` for each issue
- **Apply a shared label** to all issues from this plan (e.g., `offline-caching`, `auth-refactor`) — the implementation skill uses this label to fetch the full set via `gh issue list --label <label>`
- Include full implementation context, relevant file paths, and code snippets from the plan
- Include acceptance criteria so the implementing subagent knows when it's done
- Include the TDD micro-steps from the plan: which tests to write, expected failures, implementation approach
- Use additional label(s) to categorize (e.g., `enhancement`, `bug`, `refactor`)
- If creating multiple issues, note dependencies between them in each issue body

### Step 2: Set Up Worktree

If not already in a worktree, use **ottopowers-gh:using-git-worktrees** to create an isolated workspace before implementation.

### Step 3: Implement

- **REQUIRED SUB-SKILL:** Use ottopowers-gh:subagent-driven-development
- Implementation skill reads each issue and decides subagent count based on complexity
- Two-stage review (spec compliance → code quality) after each issue
- Subagent commits reference the issue number (e.g., `feat: add caching layer (#142)`)
