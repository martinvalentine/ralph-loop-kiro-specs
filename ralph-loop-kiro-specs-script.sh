#!/bin/bash
set -e

# ── Color & style codes ──
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

MAX_ITERATIONS=${1:-10}
SPECS_NAME=${2:-}

if [ -z "$SPECS_NAME" ]; then
  echo -e "${RED}❌ Usage: $0 <max_iterations> <specs_name>${NC}" >&2
  exit 1
fi

# Validate MAX_ITERATIONS is a positive integer
if ! [[ "$MAX_ITERATIONS" =~ ^[1-9][0-9]*$ ]]; then
  echo -e "${RED}❌ Error: <max_iterations> must be a positive integer, got '${BOLD}$MAX_ITERATIONS${RED}'${NC}" >&2
  exit 1
fi

# Validate SPECS_NAME is a non-empty string (no whitespace-only)
if ! [[ "$SPECS_NAME" =~ [^[:space:]] ]]; then
  echo -e "${RED}❌ Error: <specs_name> must be a non-empty string${NC}" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname \
  "${BASH_SOURCE[0]}")" && pwd)"

# Set the specs directory path based on the provided specs name
SPECS_DIR="$SCRIPT_DIR/.kiro/specs/$SPECS_NAME"
# Check if the specs directory exists, exit with error if not found
if [ ! -d "$SPECS_DIR" ]; then
  echo -e "${RED}❌ Error: No specs named '${BOLD}$SPECS_NAME${RED}' found in this project${NC}" >&2
  exit 1
fi

# ── Steering files pre-flight ─────────────────────────────────────────────────
STEERING_DIR="$SCRIPT_DIR/.kiro/steering"
mkdir -p "$STEERING_DIR"

STEERING_MISSING=0
MISSING_FILES=()

[ ! -f "$STEERING_DIR/product.md" ]   && STEERING_MISSING=1 && MISSING_FILES+=("product.md")
[ ! -f "$STEERING_DIR/structure.md" ] && STEERING_MISSING=1 && MISSING_FILES+=("structure.md")
[ ! -f "$STEERING_DIR/tech.md" ]      && STEERING_MISSING=1 && MISSING_FILES+=("tech.md")

if [ "$STEERING_MISSING" -eq 1 ]; then
  echo ""
  echo -e "${YELLOW}══════════════════════════════════════════════════════${NC}"
  echo -e "  ⚠️  ${BOLD}Missing steering file(s) detected${NC}"
  echo -e "${YELLOW}══════════════════════════════════════════════════════${NC}"
  echo ""
  echo -e "  The following files are missing from ${CYAN}.kiro/steering/${NC}:"
  for f in "${MISSING_FILES[@]}"; do
    echo -e "    ${RED}✗${NC}  $f"
  done
  echo ""
  echo -e "  ${BOLD}Why this matters:${NC}"
  echo -e "  ${DIM}Steering files are Ralph's first source of context in every"
  echo -e "  iteration (Phase 1). Without them, Ralph skips loading your"
  echo -e "  product/stack context, which leads to lower-quality and"
  echo -e "  inconsistent implementations across tasks.${NC}"
  echo ""
  echo -e "  ${BOLD}What each file should contain:${NC}"
  echo ""
  echo -e "  ${CYAN}product.md${NC}"
  echo -e "  ${DIM}  What the product is, who it's for, and what problem it solves."
  echo -e "  ${DIM}  Example:"
  echo -e "  ${DIM}    # Product"
  echo -e "  ${DIM}    This is a RAG application that lets users ingest documents"
  echo -e "  ${DIM}    and query them with AI. It supports PDF, DOCX, and Markdown,"
  echo -e "  ${DIM}    performs semantic search, and returns grounded cited answers.${NC}"
  echo ""
  echo -e "  ${CYAN}structure.md${NC}"
  echo -e "  ${DIM}  Directory layout and where key modules live."
  echo -e "  ${DIM}  Example:"
  echo -e "  ${DIM}    # Project Structure"
  echo -e "  ${DIM}    - src/        core application logic"
  echo -e "  ${DIM}    - tests/      unit and integration tests"
  echo -e "  ${DIM}    - data/       sample documents for ingestion${NC}"
  echo ""
  echo -e "  ${CYAN}tech.md${NC}"
  echo -e "  ${DIM}  Language, frameworks, package manager, and exact CLI commands."
  echo -e "  ${DIM}  Be specific — Ralph uses these to avoid wrong commands."
  echo -e "  ${DIM}  Example:"
  echo -e "  ${DIM}    # Tech Stack"
  echo -e "  ${DIM}    - Language: Python 3.11"
  echo -e "  ${DIM}    - Package manager: poetry"
  echo -e "  ${DIM}    - Vector store: Chroma"
  echo -e "  ${DIM}    - LLM: Anthropic Claude via API"
  echo -e "  ${DIM}    - Run tests: pytest -v --cov=src"
  echo -e "  ${DIM}    - Lint: ruff check .${NC}"
  echo ""
  echo -e "${YELLOW}══════════════════════════════════════════════════════${NC}"
  echo ""
  echo -e "${YELLOW}  Auto-create placeholder files and continue? (y/N):${NC} \c"
  read -r CREATE_STEERING
  echo ""

  if [[ "$CREATE_STEERING" =~ ^[Yy]$ ]]; then
    if [ ! -f "$STEERING_DIR/product.md" ]; then
      cat > "$STEERING_DIR/product.md" <<'EOF'
# Product

TODO: Describe what this product does, who it's for, and what problem it solves.

Example:
  This is a RAG application that lets users ingest documents and query them
  with AI. It supports PDF, DOCX, and Markdown, performs semantic search over
  indexed content, and returns grounded, cited answers.
EOF
      echo -e "  ${GREEN}✔${NC}  Created placeholder: ${CYAN}$STEERING_DIR/product.md${NC}"
    fi

    if [ ! -f "$STEERING_DIR/structure.md" ]; then
      cat > "$STEERING_DIR/structure.md" <<'EOF'
# Project Structure

TODO: Describe the directory layout and where key modules live.

Example:
  - src/        core application logic
  - tests/      unit and integration tests
  - data/       sample documents for ingestion
  - .kiro/      specs and steering files
EOF
      echo -e "  ${GREEN}✔${NC}  Created placeholder: ${CYAN}$STEERING_DIR/structure.md${NC}"
    fi

    if [ ! -f "$STEERING_DIR/tech.md" ]; then
      cat > "$STEERING_DIR/tech.md" <<'EOF'
# Tech Stack

TODO: List your language, frameworks, package manager, test runner, linter,
and exact CLI commands. Ralph reads this before every task — be specific.

Example:
  - Language: Python 3.11
  - Package manager: poetry
  - Vector store: Chroma
  - Embeddings: HuggingFace sentence-transformers
  - LLM: Anthropic Claude via API
  - Run tests: pytest -v --cov=src
  - Lint: ruff check .
EOF
      echo -e "  ${GREEN}✔${NC}  Created placeholder: ${CYAN}$STEERING_DIR/tech.md${NC}"
    fi

    echo ""
    echo -e "  ${YELLOW}⚠️  Placeholder files contain TODOs.${NC}"
    echo -e "  ${DIM}Ralph will run, but output quality improves significantly once"
    echo -e "  you replace the TODOs with real content about your project.${NC}"
    echo ""
  else
    echo -e "  ${RED}❌ Aborting.${NC} Please create the steering files and re-run."
    echo ""
    echo -e "  ${DIM}Quick start — run these commands:${NC}"
    echo ""
    echo -e "    mkdir -p .kiro/steering"
    for f in "${MISSING_FILES[@]}"; do
      echo -e "    touch .kiro/steering/$f"
    done
    echo ""
    exit 1
  fi
fi
# ─────────────────────────────────────────────────────────────────────────────

# Initialize progress log file if it doesn't exist
if [ ! -f "$SPECS_DIR/progress.md" ]; then
  echo "# Progress Log for spec: $SPECS_NAME" \
    > "$SPECS_DIR/progress.md"
  echo -e "${DIM}📝 Created progress.md${NC}"
fi

# Initialize time log file if it doesn't exist
TIME_LOG="$SPECS_DIR/specs_time.md"
if [ ! -f "$TIME_LOG" ]; then
  echo "# Time Log for spec: $SPECS_NAME" > "$TIME_LOG"
  echo -e "${DIM}📝 Created specs_time.md${NC}"
fi

# Load the prompt template and substitute the specs name placeholder
PROMPT=$(sed "s/SPECS_NAME/$SPECS_NAME/g" \
  "$SCRIPT_DIR/ralph-loop-kiro-specs-prompt.md")

# ── Rate limiting config ──────────────────────────────────────────────────────
# Delay between iterations (seconds). Increase if you hit account suspensions.
# Recommended: 30–60s for long runs (>10 iterations).
INTER_ITERATION_DELAY=30
# Pause every N iterations for a longer cooldown to avoid rate-limit triggers.
COOLDOWN_EVERY=5
COOLDOWN_DURATION=120  # 2 minutes
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo -e "${MAGENTA}══════════════════════════════════════${NC}"
echo -e "  🚀 ${BOLD}Starting Ralph${NC}"
echo -e "  ${DIM}spec:${NC}       ${CYAN}$SPECS_NAME${NC}"
echo -e "  ${DIM}iterations:${NC} ${CYAN}$MAX_ITERATIONS${NC}"
echo -e "  ${DIM}delay:${NC}      ${CYAN}${INTER_ITERATION_DELAY}s between iterations${NC}"
echo -e "  ${DIM}cooldown:${NC}   ${CYAN}${COOLDOWN_DURATION}s every ${COOLDOWN_EVERY} iterations${NC}"
echo -e "${MAGENTA}══════════════════════════════════════${NC}"
echo ""

# Ask user for iteration mode
read -r -p "$(echo -e "${YELLOW}🔄 Iterate automatically through tasks? (y/n):${NC} ")" AUTO_MODE
case "$AUTO_MODE" in
  [yY]|[yY][eE][sS])
    AUTO_MODE=true
    echo -e "   ${GREEN}✔ Auto-pilot enabled — delays active to protect your account${NC}"
    ;;
  *)
    AUTO_MODE=false
    echo -e "   ${BLUE}✔ Manual mode — you control the pace, no auto-delays${NC}"
    ;;
esac

echo ""
echo -e "${CYAN}─── 📋 Prompt ───────────────────────────${NC}"
echo "$PROMPT"
echo -e "${CYAN}──────────────────────────────────────────${NC}"
echo ""

read -r -p "$(echo -e "${YELLOW}👀 Review the prompt above. Press Enter to launch the Ralph loop...${NC} ")"
echo ""

for i in $(seq 1 $MAX_ITERATIONS); do
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "  🔁 ${BOLD}Iteration ${CYAN}$i${NC}${BOLD} / ${DIM}$MAX_ITERATIONS${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"

  OUTPUT=$(echo "$PROMPT" \
    | kiro-cli chat --trust-all-tools --no-interactive 2>&1 \
    | tee /dev/stderr) || true

  # ── Detect account suspension / access denied errors ─────────────────────
  if echo "$OUTPUT" | grep -qi "AccessDenied\|suspended\|security precaution\|verify your identity\|account.*locked\|temporarily.*suspended"; then
    echo ""
    echo -e "${RED}══════════════════════════════════════════════════════${NC}"
    echo -e "  🚨 ${BOLD}Account access error detected — stopping loop${NC}"
    echo -e "${RED}══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${BOLD}What happened:${NC}"
    echo -e "  ${DIM}Kiro's backend (AWS) temporarily suspended your account,"
    echo -e "  likely triggered by rapid consecutive API calls exceeding"
    echo -e "  a rate-limit or abuse detection threshold.${NC}"
    echo ""
    echo -e "  ${BOLD}What to do now:${NC}"
    echo -e "  ${DIM}1. Contact AWS support via the link shown in the error above${NC}"
    echo -e "  ${DIM}2. Wait for account restoration (usually a few hours)${NC}"
    echo -e "  ${DIM}3. Increase INTER_ITERATION_DELAY (currently ${INTER_ITERATION_DELAY}s)"
    echo -e "     and COOLDOWN_DURATION (currently ${COOLDOWN_DURATION}s) in this script${NC}"
    echo -e "  ${DIM}4. Use manual mode next time to control pacing yourself${NC}"
    echo ""
    echo -e "  ${BOLD}Resuming later:${NC}"
    echo -e "  ${DIM}Your progress is saved in:${NC}"
    echo -e "  ${CYAN}  $SPECS_DIR/progress.md${NC}"
    echo -e "  ${DIM}Re-run with the same arguments — Ralph reads tasks.md and"
    echo -e "  automatically picks up from the next incomplete task.${NC}"
    echo ""
    exit 2
  fi
  # ─────────────────────────────────────────────────────────────────────────

  if echo "$OUTPUT" | \
    grep -q "<promise>COMPLETE</promise>"
  then
    echo ""
    echo -e "${GREEN}══════════════════════════════════════${NC}"
    echo -e "  ✅  ${BOLD}All tasks complete!${NC}"
    echo -e "${GREEN}══════════════════════════════════════${NC}"
    exit 0
  fi

  if [ "$AUTO_MODE" = false ]; then
    echo ""
    read -r -p "$(echo -e "${YELLOW}⏸️  Iteration $i done. Press Enter to continue...${NC} ")"
  else
    # ── Auto mode: rate limiting between iterations ───────────────────────
    if [ "$i" -lt "$MAX_ITERATIONS" ]; then
      if [ $(( i % COOLDOWN_EVERY )) -eq 0 ]; then
        # Longer cooldown every COOLDOWN_EVERY iterations
        echo ""
        echo -e "  ${MAGENTA}☕ Cooldown after iteration $i — waiting ${COOLDOWN_DURATION}s to protect your account...${NC}"
        secs=$COOLDOWN_DURATION
        while [ $secs -gt 0 ]; do
          echo -ne "     ${DIM}Resuming in ${secs}s...   ${NC}\r"
          sleep 1
          secs=$(( secs - 1 ))
        done
        echo -ne "\r\033[K"
      else
        # Standard inter-iteration delay
        echo ""
        echo -e "  ${DIM}⏳ Waiting ${INTER_ITERATION_DELAY}s before next iteration...${NC}"
        secs=$INTER_ITERATION_DELAY
        while [ $secs -gt 0 ]; do
          echo -ne "     ${DIM}Next iteration in ${secs}s...   ${NC}\r"
          sleep 1
          secs=$(( secs - 1 ))
        done
        echo -ne "\r\033[K"
      fi
    fi
    # ─────────────────────────────────────────────────────────────────────
  fi

done

echo ""
echo -e "${RED}══════════════════════════════════════${NC}"
echo -e "  ⚠️  ${BOLD}Max iterations reached${NC} ${DIM}($MAX_ITERATIONS)${NC}"
echo -e "${RED}══════════════════════════════════════${NC}"
exit 1
