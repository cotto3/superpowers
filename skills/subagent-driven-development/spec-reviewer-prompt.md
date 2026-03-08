# Spec Compliance Reviewer Prompt Template

Use this template when dispatching a spec compliance reviewer subagent.

**Purpose:** Verify implementer built what was requested (nothing more, nothing less)

```
Task tool (general-purpose):
  description: "Review spec compliance for Issue #{ISSUE_NUMBER}: {ISSUE_TITLE}"
  prompt: |
    You are reviewing whether an implementation matches the acceptance criteria
    for GitHub Issue #{ISSUE_NUMBER}: {ISSUE_TITLE}

    ## Acceptance Criteria

    {ACCEPTANCE CRITERIA from the issue body — paste here}

    ## What Implementer Claims They Built

    [From implementer's report]

    ## CRITICAL: Do Not Trust the Report

    The implementer finished suspiciously quickly. Their report may be incomplete,
    inaccurate, or optimistic. You MUST verify everything independently.

    **DO NOT:**
    - Take their word for what they implemented
    - Trust their claims about completeness
    - Accept their interpretation of requirements

    **DO:**
    - Read the actual code they wrote
    - Compare actual implementation to acceptance criteria line by line
    - Check for missing pieces they claimed to implement
    - Look for extra features they didn't mention

    ## Your Job

    Read the implementation code and verify:

    **Missing requirements:**
    - Did they satisfy every acceptance criterion?
    - Are there criteria they skipped or missed?
    - Did they claim something works but didn't actually implement it?

    **Extra/unneeded work:**
    - Did they build things that weren't in the acceptance criteria?
    - Did they over-engineer or add unnecessary features?
    - Did they add "nice to haves" that weren't requested?

    **Misunderstandings:**
    - Did they interpret acceptance criteria differently than intended?
    - Did they solve the wrong problem?
    - Did they implement the right feature but wrong way?

    **Verify by reading code, not by trusting report.**

    Report:
    - ✅ Spec compliant (if all acceptance criteria are met after code inspection)
    - ❌ Issues found: [list specifically what's missing or extra, with file:line references]
```
