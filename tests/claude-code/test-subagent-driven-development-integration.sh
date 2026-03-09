#!/usr/bin/env bash
# Integration Test: subagent-driven-development workflow
# Executes the issue-driven workflow with mocked gh CLI responses
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "========================================"
echo " Integration Test: subagent-driven-development"
echo "========================================"
echo ""
echo "This test executes the issue-driven workflow and verifies:"
echo "  1. GitHub issues are fetched via gh"
echo "  2. Worktree setup happens before implementation"
echo "  3. Issue dependencies drive execution order"
echo "  4. Per-issue review loop tooling is invoked"
echo "  5. Commits reference issue numbers"
echo "  6. PR body includes Closes #N references"
echo ""
echo "WARNING: This test may take 10-30 minutes to complete."
echo ""

PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_PROJECT=$(create_test_project)
ORIGIN_REPO=$(mktemp -d)
ORIGIN_GIT="$ORIGIN_REPO/origin.git"
OUTPUT_FILE="$TEST_PROJECT/claude-output.txt"
GH_LOG="$TEST_PROJECT/gh-calls.log"
GH_PR_BODY="$TEST_PROJECT/gh-pr-body.txt"
SESSION_MARKER="sdd-integration-$(date +%s)"

echo "Plugin dir: $PLUGIN_DIR"
echo "Test project: $TEST_PROJECT"

cleanup() {
    cleanup_test_project "$TEST_PROJECT"
    rm -rf "$ORIGIN_REPO"
}
trap cleanup EXIT

cd "$TEST_PROJECT"

cat > package.json <<'EOF'
{
  "name": "test-project",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "test": "node --test"
  }
}
EOF

mkdir -p src test .worktrees mock-bin

cat > .gitignore <<'EOF'
.worktrees/
EOF

cat > test/smoke.test.js <<'EOF'
import test from 'node:test';
import assert from 'node:assert/strict';

test('baseline test project is healthy', () => {
  assert.equal(1 + 1, 2);
});
EOF

cat > mock-bin/gh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%q ' "$@" >> "${GH_MOCK_LOG:?}"
printf '\n' >> "${GH_MOCK_LOG:?}"

if [[ "${1:-}" == "issue" && "${2:-}" == "list" ]]; then
  cat <<'JSON'
[
  {
    "number": 102,
    "title": "Add multiply function",
    "body": "Implement multiplication support for the math helper.\n\nDepends on #101\n\nAcceptance Criteria:\n- Export `multiply(a, b)` from `src/math.js`\n- Add tests in `test/math.test.js` covering positive, zero, and negative multiplication\n- Do not add divide, subtract, or power helpers\n- Run `npm test` before committing\n"
  },
  {
    "number": 101,
    "title": "Add add function",
    "body": "Implement addition support for the math helper.\n\nAcceptance Criteria:\n- Export `add(a, b)` from `src/math.js`\n- Add tests in `test/math.test.js` covering positive, zero, and negative addition\n- Run `npm test` before committing\n"
  }
]
JSON
  exit 0
fi

if [[ "${1:-}" == "issue" && "${2:-}" == "view" ]]; then
  case "${3:-}" in
    101)
      cat <<'JSON'
{"title":"Add add function","body":"Implement addition support for the math helper.\n\nAcceptance Criteria:\n- Export `add(a, b)` from `src/math.js`\n- Add tests in `test/math.test.js` covering positive, zero, and negative addition\n- Run `npm test` before committing\n"}
JSON
      ;;
    102)
      cat <<'JSON'
{"title":"Add multiply function","body":"Implement multiplication support for the math helper.\n\nDepends on #101\n\nAcceptance Criteria:\n- Export `multiply(a, b)` from `src/math.js`\n- Add tests in `test/math.test.js` covering positive, zero, and negative multiplication\n- Do not add divide, subtract, or power helpers\n- Run `npm test` before committing\n"}
JSON
      ;;
    *)
      echo "Unsupported issue number: ${3:-}" >&2
      exit 1
      ;;
  esac
  exit 0
fi

if [[ "${1:-}" == "pr" && "${2:-}" == "create" ]]; then
  body=""
  prev=""
  for arg in "$@"; do
    if [[ "$prev" == "--body" ]]; then
      body="$arg"
      break
    fi
    prev="$arg"
  done
  printf '%s\n' "$body" > "${GH_PR_BODY_LOG:?}"
  echo "https://example.com/pull/123"
  exit 0
fi

echo "gh mock: unsupported command: $*" >&2
exit 1
EOF
chmod +x mock-bin/gh

git init -b main --quiet
git config user.email "test@test.com"
git config user.name "Test User"
git add .
git commit -m "Initial commit" --quiet

git init --bare --quiet "$ORIGIN_GIT"
git remote add origin "$ORIGIN_GIT"
git push -u origin main --quiet

echo ""
echo "Project setup complete. Starting execution..."
echo ""

PROMPT="Session marker: $SESSION_MARKER

Change to directory $TEST_PROJECT and use the subagent-driven-development skill to implement the open GitHub issues with label math-workflow in this session.

Follow the issue bodies and acceptance criteria exactly. Use the normal workflow skills, including worktree setup before implementation. When the work is complete, use finishing-a-development-branch and choose Option 2 (Push and create a Pull Request).

The git remote is already configured locally. Proceed without asking follow-up questions unless the skill absolutely requires it."

echo "Running Claude (output will be shown below and saved to $OUTPUT_FILE)..."
echo "================================================================================"
cd "$PLUGIN_DIR"
PATH="$TEST_PROJECT/mock-bin:$PATH" \
GH_MOCK_LOG="$GH_LOG" \
GH_PR_BODY_LOG="$GH_PR_BODY" \
run_with_timeout 1800 claude -p "$PROMPT" \
    --plugin-dir "$PLUGIN_DIR" \
    --allowed-tools=all \
    --add-dir "$TEST_PROJECT" \
    --permission-mode bypassPermissions \
    2>&1 | tee "$OUTPUT_FILE" || {
        echo ""
        echo "================================================================================"
        echo "EXECUTION FAILED (exit code: $?)"
        exit 1
    }
echo "================================================================================"

echo ""
echo "Execution complete. Analyzing results..."
echo ""

WORKING_DIR_ESCAPED=$(echo "$PLUGIN_DIR" | sed 's/\//-/g' | sed 's/^-//')
SESSION_DIR="$HOME/.claude/projects/$WORKING_DIR_ESCAPED"
SESSION_FILE=$(
    find "$SESSION_DIR" -name "*.jsonl" -type f -mmin -60 2>/dev/null | while read -r file; do
        if grep -q "$SESSION_MARKER" "$file" 2>/dev/null; then
            echo "$file"
            break
        fi
    done
)

if [ -z "$SESSION_FILE" ]; then
    echo "ERROR: Could not find session transcript file for marker $SESSION_MARKER"
    echo "Looked in: $SESSION_DIR"
    exit 1
fi

echo "Analyzing session transcript: $(basename "$SESSION_FILE")"
echo ""

FAILED=0

echo "=== Verification Tests ==="
echo ""

echo "Test 1: Skills invoked..."
if { grep -q '"name":"Skill".*"skill":"superpowers:subagent-driven-development"' "$SESSION_FILE" || grep -q 'skills/subagent-driven-development/SKILL.md' "$SESSION_FILE"; }; then
    echo "  [PASS] subagent-driven-development skill was invoked"
else
    echo "  [FAIL] subagent-driven-development skill was not invoked"
    FAILED=$((FAILED + 1))
fi

if { grep -q '"name":"Skill".*"skill":"superpowers:using-git-worktrees"' "$SESSION_FILE" || grep -q 'skills/using-git-worktrees/SKILL.md' "$SESSION_FILE"; }; then
    echo "  [PASS] using-git-worktrees skill was invoked"
else
    echo "  [FAIL] using-git-worktrees skill was not invoked"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "Test 2: Issue tracking and fetch..."
todo_count=$(grep -c '"name":"TodoWrite"' "$SESSION_FILE" || true)
if [ "$todo_count" -ge 1 ]; then
    echo "  [PASS] TodoWrite used $todo_count time(s)"
else
    echo "  [FAIL] TodoWrite not used"
    FAILED=$((FAILED + 1))
fi

if grep -qE 'issue list .*--label .*math-workflow' "$GH_LOG"; then
    echo "  [PASS] gh issue list called for shared label"
else
    echo "  [FAIL] gh issue list was not called with the expected label"
    FAILED=$((FAILED + 1))
fi

if { grep -q 'issue view 101' "$GH_LOG" && grep -q 'issue view 102' "$GH_LOG"; } || { grep -q 'Issue #101' "$SESSION_FILE" && grep -q 'Issue #102' "$SESSION_FILE"; }; then
    echo "  [PASS] both issues were read and processed"
else
    echo "  [FAIL] could not verify that both issues were processed"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "Test 3: Worktree creation..."
if grep -q 'git worktree add' "$SESSION_FILE"; then
    echo "  [PASS] session transcript shows git worktree add"
else
    echo "  [FAIL] session transcript does not show git worktree add"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "Test 4: Review ordering..."
spec_line=$(grep -nE 'spec-reviewer-prompt\.md|Stage 1: Spec compliance review|Spec review Issue #' "$SESSION_FILE" | head -1 | cut -d: -f1 || true)
code_line=$(grep -nE 'code-quality-reviewer-prompt\.md|Stage 2: Code quality review|Code quality review Issue #' "$SESSION_FILE" | head -1 | cut -d: -f1 || true)
if [ -n "$spec_line" ] && [ -n "$code_line" ] && [ "$spec_line" -lt "$code_line" ]; then
    echo "  [PASS] spec review dispatched before code quality review"
else
    echo "  [FAIL] could not verify spec review before code quality review"
    FAILED=$((FAILED + 1))
fi
echo ""

FEATURE_BRANCH=$(git -C "$TEST_PROJECT" for-each-ref --format='%(refname:short)' refs/heads | grep -v '^main$' | head -1 || true)
if [ -z "$FEATURE_BRANCH" ]; then
    echo "Test 5: Feature branch detection..."
    echo "  [FAIL] No feature branch found after execution"
    FAILED=$((FAILED + 1))
else
    echo "Test 5: Implementation artifacts..."
    echo "  Feature branch: $FEATURE_BRANCH"

    if git -C "$TEST_PROJECT" show "$FEATURE_BRANCH:src/math.js" > "$TEST_PROJECT/math.js"; then
        echo "  [PASS] src/math.js exists on feature branch"
    else
        echo "  [FAIL] src/math.js missing on feature branch"
        FAILED=$((FAILED + 1))
    fi

    if git -C "$TEST_PROJECT" show "$FEATURE_BRANCH:test/math.test.js" > "$TEST_PROJECT/math.test.js"; then
        echo "  [PASS] test/math.test.js exists on feature branch"
    else
        echo "  [FAIL] test/math.test.js missing on feature branch"
        FAILED=$((FAILED + 1))
    fi

    if grep -q 'export function add' "$TEST_PROJECT/math.js" && grep -q 'export function multiply' "$TEST_PROJECT/math.js"; then
        echo "  [PASS] add and multiply functions exist"
    else
        echo "  [FAIL] add and multiply functions not both present"
        FAILED=$((FAILED + 1))
    fi

    if grep -qE 'export function (divide|subtract|power)' "$TEST_PROJECT/math.js"; then
        echo "  [FAIL] unexpected extra math helpers found"
        FAILED=$((FAILED + 1))
    else
        echo "  [PASS] no unexpected extra math helpers"
    fi
    echo ""

    echo "Test 6: Tests pass on implemented branch..."
    VERIFY_DIR="$TEST_PROJECT/verify-worktree"
    git -C "$TEST_PROJECT" worktree add --quiet --detach "$VERIFY_DIR" "$FEATURE_BRANCH"
    if (cd "$VERIFY_DIR" && npm test > "$TEST_PROJECT/test-output.txt" 2>&1); then
        echo "  [PASS] npm test passes on implemented branch"
    else
        echo "  [FAIL] npm test failed on implemented branch"
        sed 's/^/    /' "$TEST_PROJECT/test-output.txt"
        FAILED=$((FAILED + 1))
    fi
    git -C "$TEST_PROJECT" worktree remove "$VERIFY_DIR" --force >/dev/null 2>&1 || true
    echo ""

    echo "Test 7: Commit history and dependency order..."
    if git -C "$TEST_PROJECT" log --oneline "$FEATURE_BRANCH" --grep='\(#101\)' | grep -q .; then
        echo "  [PASS] found commit(s) referencing #101"
    else
        echo "  [FAIL] no commits reference #101"
        FAILED=$((FAILED + 1))
    fi

    if git -C "$TEST_PROJECT" log --oneline "$FEATURE_BRANCH" --grep='\(#102\)' | grep -q .; then
        echo "  [PASS] found commit(s) referencing #102"
    else
        echo "  [FAIL] no commits reference #102"
        FAILED=$((FAILED + 1))
    fi

    mapfile -t commit_subjects < <(git -C "$TEST_PROJECT" log --reverse --format='%s' main.."$FEATURE_BRANCH")
    first_101=0
    first_102=0
    for i in "${!commit_subjects[@]}"; do
        if [ "$first_101" -eq 0 ] && echo "${commit_subjects[$i]}" | grep -q '(#101)'; then
            first_101=$((i + 1))
        fi
        if [ "$first_102" -eq 0 ] && echo "${commit_subjects[$i]}" | grep -q '(#102)'; then
            first_102=$((i + 1))
        fi
    done

    if [ "$first_101" -gt 0 ] && [ "$first_102" -gt 0 ] && [ "$first_101" -lt "$first_102" ]; then
        echo "  [PASS] issue #101 was implemented before #102"
    else
        echo "  [FAIL] could not verify dependency order (#101 before #102)"
        FAILED=$((FAILED + 1))
    fi
    echo ""
fi

echo "Test 8: PR closing references..."
if [ -f "$GH_PR_BODY" ] && grep -q 'Closes #101' "$GH_PR_BODY" && grep -q 'Closes #102' "$GH_PR_BODY"; then
    echo "  [PASS] PR body includes Closes #101 and Closes #102"
else
    echo "  [FAIL] PR body missing expected Closes #N references"
    if [ -f "$GH_PR_BODY" ]; then
        sed 's/^/    /' "$GH_PR_BODY"
    fi
    FAILED=$((FAILED + 1))
fi
echo ""

echo "========================================="
echo " Token Usage Analysis"
echo "========================================="
echo ""
python3 "$SCRIPT_DIR/analyze-token-usage.py" "$SESSION_FILE"
echo ""

echo "========================================"
echo " Test Summary"
echo "========================================"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "STATUS: PASSED"
    echo "All verification tests passed!"
    exit 0
else
    echo "STATUS: FAILED"
    echo "Failed $FAILED verification tests"
    echo ""
    echo "Output saved to: $OUTPUT_FILE"
    exit 1
fi
