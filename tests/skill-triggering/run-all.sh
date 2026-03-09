#!/bin/bash
# Run maintained skill-triggering tests by default.
# Use --experimental to include older broad trigger prompts.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"

DEFAULT_SKILLS=(
    "subagent-driven-development"
)

EXPERIMENTAL_SKILLS=(
    "systematic-debugging"
    "test-driven-development"
    "writing-plans"
    "dispatching-parallel-agents"
    "executing-plans"
    "requesting-code-review"
)

SKILLS=("${DEFAULT_SKILLS[@]}")
MAX_TURNS=3
RUN_EXPERIMENTAL=false
SPECIFIC_SKILL=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --experimental|-e)
            RUN_EXPERIMENTAL=true
            shift
            ;;
        --skill|-s)
            SPECIFIC_SKILL="$2"
            shift 2
            ;;
        --max-turns)
            MAX_TURNS="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --experimental, -e  Include broader legacy/upstream trigger prompts"
            echo "  --skill, -s NAME    Run only one skill trigger test"
            echo "  --max-turns N       Override max turns passed to run-test.sh (default: 3)"
            echo "  --help, -h          Show this help"
            echo ""
            echo "Default maintained trigger tests:"
            printf '  %s\n' "${DEFAULT_SKILLS[@]}"
            echo ""
            echo "Experimental legacy/upstream trigger tests:"
            printf '  %s\n' "${EXPERIMENTAL_SKILLS[@]}"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ "$RUN_EXPERIMENTAL" = true ]; then
    SKILLS+=("${EXPERIMENTAL_SKILLS[@]}")
fi

if [ -n "$SPECIFIC_SKILL" ]; then
    SKILLS=("$SPECIFIC_SKILL")
fi

echo "=== Running Skill Triggering Tests ==="
if [ "$RUN_EXPERIMENTAL" = false ] && [ -z "$SPECIFIC_SKILL" ]; then
    echo "Mode: maintained fork-specific coverage only"
    echo "Use --experimental to add broader legacy/upstream prompts."
else
    echo "Mode: expanded"
fi
echo ""

PASSED=0
FAILED=0
RESULTS=()

for skill in "${SKILLS[@]}"; do
    prompt_file="$PROMPTS_DIR/${skill}.txt"

    if [ ! -f "$prompt_file" ]; then
        echo "⚠️  SKIP: No prompt file for $skill"
        continue
    fi

    echo "Testing: $skill"

    if "$SCRIPT_DIR/run-test.sh" "$skill" "$prompt_file" "$MAX_TURNS" 2>&1 | tee /tmp/skill-test-$skill.log; then
        PASSED=$((PASSED + 1))
        RESULTS+=("✅ $skill")
    else
        FAILED=$((FAILED + 1))
        RESULTS+=("❌ $skill")
    fi

    echo ""
    echo "---"
    echo ""
done

echo ""
echo "=== Summary ==="
for result in "${RESULTS[@]}"; do
    echo "  $result"
done
echo ""
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
