#!/usr/bin/env bash
# Static contract test for the customized GitHub-issues workflow.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

FAILED=0

assert_file_contains() {
    local file="$1"
    local pattern="$2"
    local test_name="$3"

    if grep -Eq "$pattern" "$file"; then
        echo "  [PASS] $test_name"
    else
        echo "  [FAIL] $test_name"
        echo "  Expected to find pattern: $pattern"
        echo "  File: $file"
        FAILED=$((FAILED + 1))
    fi
}

assert_file_not_contains() {
    local file="$1"
    local pattern="$2"
    local test_name="$3"

    if grep -Eq "$pattern" "$file"; then
        echo "  [FAIL] $test_name"
        echo "  Did not expect pattern: $pattern"
        echo "  File: $file"
        FAILED=$((FAILED + 1))
    else
        echo "  [PASS] $test_name"
    fi
}

CLAUDE_MD="$ROOT_DIR/CLAUDE.md"
WRITING_PLANS="$ROOT_DIR/skills/writing-plans/SKILL.md"
SUBAGENT_DEV="$ROOT_DIR/skills/subagent-driven-development/SKILL.md"
REQUEST_REVIEW="$ROOT_DIR/skills/requesting-code-review/SKILL.md"
WORKTREES="$ROOT_DIR/skills/using-git-worktrees/SKILL.md"
FINISHING="$ROOT_DIR/skills/finishing-a-development-branch/SKILL.md"

echo "=== Test: customized workflow contracts ==="
echo ""

echo "Test 1: CLAUDE.md workflow contract..."
assert_file_contains "$CLAUDE_MD" "brainstorming .+ writing-plans .+ using-git-worktrees .+ subagent-driven-development .+ finishing-a-development-branch" "Primary workflow includes worktree step"
assert_file_contains "$CLAUDE_MD" "Alternative workflow:.*executing-plans.*separate session.*not the default path" "CLAUDE.md keeps executing-plans as explicit alternative"
echo ""

echo "Test 2: writing-plans execution handoff..."
assert_file_contains "$WRITING_PLANS" "Planning can happen in the current workspace" "Planning is allowed outside a worktree"
assert_file_contains "$WRITING_PLANS" "If not already in a worktree, use \\*\\*ottopowers-gh:using-git-worktrees\\*\\*" "writing-plans hands off to worktree setup"
assert_file_contains "$WRITING_PLANS" "default workflow for the customized GitHub Issues path" "writing-plans documents the default issue-driven path"
echo ""

echo "Test 3: subagent-driven-development contract..."
assert_file_contains "$SUBAGENT_DEV" "^description: .*Use when GitHub issues already exist" "SDD description is trigger-oriented"
assert_file_not_contains "$SUBAGENT_DEV" "^description: .*reads each issue" "SDD description avoids workflow-summary shortcut"
assert_file_contains "$SUBAGENT_DEV" "If not already in an isolated workspace, use \\*\\*ottopowers-gh:using-git-worktrees\\*\\*" "SDD requires isolated workspace before code changes"
echo ""

echo "Test 4: requesting-code-review alignment..."
assert_file_contains "$REQUEST_REVIEW" "After implementation is complete for an issue in subagent-driven development" "Review cadence is once per issue"
assert_file_not_contains "$REQUEST_REVIEW" "After each task in subagent-driven development" "Old per-task review rule removed"
assert_file_contains "$REQUEST_REVIEW" "Review once per issue, after implementation is complete and spec compliance has already passed" "Integration text matches issue-level review flow"
echo ""

echo "Test 5: using-git-worktrees integration..."
assert_file_contains "$WORKTREES" "\\*\\*writing-plans\\*\\* \\(execution handoff\\)" "Worktree skill integrates with writing-plans handoff"
assert_file_not_contains "$WORKTREES" "\\*\\*brainstorming\\*\\* \\(Phase 4\\)" "Old brainstorming integration removed"
echo ""

echo "Test 6: finishing-a-development-branch cleanup rules..."
assert_file_contains "$FINISHING" "Only keep the worktree for Option 3\\. Clean up for Options 1, 2, and 4\\." "Cleanup rule matches Option 2 PR flow"
assert_file_contains "$FINISHING" "Clean up worktree for Options 1, 2, and 4" "Red flags section matches cleanup rule"
assert_file_not_contains "$FINISHING" "Only cleanup for Options 1 and 4" "Old cleanup rule removed"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo "=== All customized workflow contract tests passed ==="
    exit 0
else
    echo "=== Customized workflow contract tests failed: $FAILED ==="
    exit 1
fi
