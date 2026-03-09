# Code Quality Reviewer Prompt Template

Use this template to build the prompt body for a code quality reviewer subagent. Fill the placeholders into `requesting-code-review/code-reviewer.md`, then dispatch the rendered prompt with your environment's subagent or task mechanism.

**Purpose:** Verify implementation is well-built (clean, tested, maintainable)

**Only dispatch after spec compliance review passes.**

```text
Use `requesting-code-review/code-reviewer.md` as the prompt template.

Fill these placeholders:
- WHAT_WAS_IMPLEMENTED: [from implementer's report]
- PLAN_OR_REQUIREMENTS: Acceptance criteria from GitHub Issue #{ISSUE_NUMBER}
- BASE_SHA: [commit before issue implementation]
- HEAD_SHA: [current commit]
- DESCRIPTION: Issue #{ISSUE_NUMBER}: {ISSUE_TITLE}
```

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment
