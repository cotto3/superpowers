# Implementer Subagent Prompt Template (GitHub Issues Mode)

Use this template when dispatching an implementer subagent for a GitHub issue.

```
Task tool (general-purpose):
  description: "Implement Issue #{ISSUE_NUMBER}: {ISSUE_TITLE}"
  prompt: |
    You are implementing GitHub Issue #{ISSUE_NUMBER}: {ISSUE_TITLE}

    ## Issue Description

    {FULL ISSUE BODY - paste here, don't make subagent fetch the issue}

    ## Acceptance Criteria

    {ACCEPTANCE CRITERIA from the issue body - extract and paste here}

    ## Context

    {Scene-setting: where this fits in the broader feature, dependencies on other issues, architectural context}

    ## Before You Begin

    If you have questions about:
    - The requirements or acceptance criteria
    - The approach or implementation strategy
    - Dependencies or assumptions
    - Anything unclear in the issue description

    **Ask them now.** Raise any concerns before starting work.

    ## Your Job

    Once you're clear on requirements:
    1. Implement exactly what the issue specifies
    2. Write tests (following TDD if applicable)
    3. Verify implementation works
    4. Commit your work — **all commits must reference the issue: `feat: <description> (#{ISSUE_NUMBER})`**
    5. Self-review (see below)
    6. Report back

    Work from: {DIRECTORY}

    **While you work:** If you encounter something unexpected or unclear, **ask questions**.
    It's always OK to pause and clarify. Don't guess or make assumptions.

    ## Before Reporting Back: Self-Review

    Review your work with fresh eyes. Ask yourself:

    **Completeness:**
    - Did I satisfy every acceptance criterion?
    - Did I miss any requirements from the issue?
    - Are there edge cases I didn't handle?

    **Quality:**
    - Is this my best work?
    - Are names clear and accurate (match what things do, not how they work)?
    - Is the code clean and maintainable?

    **Discipline:**
    - Did I avoid overbuilding (YAGNI)?
    - Did I only build what was requested in the issue?
    - Did I follow existing patterns in the codebase?

    **Testing:**
    - Do tests actually verify behavior (not just mock behavior)?
    - Did I follow TDD if required?
    - Are tests comprehensive?

    If you find issues during self-review, fix them now before reporting.

    ## Report Format

    When done, report:
    - Issue #{ISSUE_NUMBER} status: what acceptance criteria are met
    - What you implemented
    - What you tested and test results
    - Files changed
    - Self-review findings (if any)
    - Any issues or concerns
```

## Notes

- Commits must include `(#ISSUE_NUMBER)` for GitHub auto-linking
- Self-review checks against acceptance criteria
- Report format includes acceptance criteria status
- For sub-tasks within a complex issue, add context about which sub-task this is and what previous subagents completed
