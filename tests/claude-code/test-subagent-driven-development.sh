#!/usr/bin/env bash
# Test: subagent-driven-development skill
# Verifies that the skill is loaded and follows the issue-driven workflow
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "=== Test: subagent-driven-development skill ==="
echo ""

# Test 1: Verify skill can be loaded
echo "Test 1: Skill loading..."

output=$(run_claude "What is the subagent-driven-development skill used for in this plugin now? Answer in 2-4 short bullets." 30)

if assert_contains "$output" "GitHub issue\|GitHub Issues\|adaptive subagent\|two-stage review" "Skill behavior is recognized"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "GitHub issue\|GitHub Issues\|issues" "Mentions GitHub issues"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 2: Verify skill describes correct workflow order
echo "Test 2: Workflow ordering..."

output=$(run_claude "In the subagent-driven-development skill, what comes first: spec compliance review or code quality review? Be specific about the order." 30)

if assert_contains "$output" "spec.*first\|first.*spec\|spec.*before.*code.*quality" "Spec compliance before code quality"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 3: Verify self-review is mentioned
echo "Test 3: Self-review requirement..."

output=$(run_claude "Does the subagent-driven-development skill require implementers to do self-review? What should they check?" 30)

if assert_contains "$output" "self-review\|self review" "Mentions self-review"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "completeness\|Completeness" "Checks completeness"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 4: Verify issue context is provided directly
echo "Test 4: Issue context provision..."

output=$(run_claude "In subagent-driven-development, how does the controller give context to an implementer subagent? Does the subagent need to open the plan file, or does it get the issue body and acceptance criteria directly?" 30)

if assert_contains "$output" "issue body\|full issue\|acceptance criteria\|provide.*directly" "Provides issue body and acceptance criteria directly"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "plan file.*never involved\|doesn't need to open.*plan file\|never opens the plan file\|instead of reading the plan file" "Doesn't require implementer to read plan file"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 5: Verify spec compliance reviewer is skeptical
echo "Test 5: Spec compliance reviewer mindset..."

output=$(run_claude "What is the spec compliance reviewer's attitude toward the implementer's report in subagent-driven-development?" 30)

if assert_contains "$output" "not trust\|don't trust\|skeptical\|verify.*independently\|suspiciously" "Reviewer is skeptical"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "read.*code\|inspect.*code\|verify.*code" "Reviewer reads code"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 6: Verify review loops
echo "Test 6: Review loop requirements..."

output=$(run_claude "In subagent-driven-development, what happens if a reviewer finds issues? Is it a one-time review or a loop?" 30)

if assert_contains "$output" "loop\|again\|repeat\|until.*approved\|until.*compliant" "Review loops mentioned"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "implementer.*fix\|fix.*issues" "Implementer fixes issues"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 7: Verify commit message issue references
echo "Test 7: Issue-number commit references..."

output=$(run_claude "In subagent-driven-development, what should implementer commit messages include?" 30)

if assert_contains "$output" "issue number\|#142\|#<issue-number>\|(#" "Mentions issue-number commit references"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 8: Verify worktree requirement
echo "Test 8: Worktree requirement..."

output=$(run_claude "What workflow skills are required before using subagent-driven-development? List any prerequisites or required skills." 30)

if assert_contains "$output" "using-git-worktrees\|worktree" "Mentions worktree requirement"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 9: Verify difference from executing-plans
echo "Test 9: Workflow distinction..."

output=$(run_claude "How is subagent-driven-development different from executing-plans in this repo?" 30)

if assert_contains "$output" "GitHub issue\|GitHub Issues" "Mentions issue-driven path"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "separate session\|plan-file\|plan file" "Mentions separate-session plan-file alternative"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 10: Verify finishing requirement
echo "Test 10: PR closing references..."

output=$(run_claude "After subagent-driven-development finishes all issues, what must the PR body include?" 30)

if assert_contains "$output" "Closes #\|close.*issue\|issue number" "Mentions Closes #N PR requirement"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 11: Verify main branch warning
echo "Test 11: Main branch red flag..."

output=$(run_claude "In subagent-driven-development, is it okay to start implementation directly on the main branch?" 30)

if assert_contains "$output" "worktree\|feature.*branch\|not.*main\|never.*main\|avoid.*main\|don't.*main\|consent\|permission" "Warns against main branch"; then
    : # pass
else
    exit 1
fi

echo ""

echo "=== All subagent-driven-development skill tests passed ==="
