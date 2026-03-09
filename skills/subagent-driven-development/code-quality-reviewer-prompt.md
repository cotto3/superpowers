# Code Quality Reviewer Prompt Template

Use this template when dispatching a code quality reviewer subagent.

**Purpose:** Verify implementation is well-built (clean, tested, maintainable)

**Only dispatch after spec compliance review passes.**

```
Task tool (superpowers:code-reviewer):
  Use template at requesting-code-review/code-reviewer.md

  WHAT_WAS_IMPLEMENTED: [from implementer's report]
  PLAN_OR_REQUIREMENTS: Acceptance criteria from GitHub Issue #{ISSUE_NUMBER}
  BASE_SHA: [commit before issue implementation]
  HEAD_SHA: [current commit]
  DESCRIPTION: Issue #{ISSUE_NUMBER}: {ISSUE_TITLE}
```

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment
