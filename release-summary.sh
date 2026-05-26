#!/bin/bash
# ============================================================
# release-summary — 自动生成 Git 发版变更摘要
# https://github.com/DavidMachile/release-summary
# ============================================================
# 用法:
#   release-summary <commit1> <commit2>     # 两个 commit 之间
#   release-summary <commit1>               # commit1 到 HEAD
#   release-summary -n "项目名" <from> <to>
#   release-summary -o output.md <from> <to>
#
# 依赖: git（必需）、claude CLI（可选，用于 AI 总结）
# ============================================================

set -eu

VERSION="1.0.0"
OUTPUT_FILE="RELEASE_SUMMARY.md"
PROJECT_NAME=""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
usage() {
    sed -n '2,12p' "$(which "$0" 2>/dev/null || echo "$0")" 2>/dev/null || {
        echo "Usage: release-summary <commit1> [commit2]"
        echo "       release-summary -n \"Project\" <from> <to>"
    }
    exit 0
}

FROM=""
TO="HEAD"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage ;;
        -v|--version) echo "v$VERSION"; exit 0 ;;
        -o|--output) OUTPUT_FILE="$2"; shift 2 ;;
        -n|--name)   PROJECT_NAME="$2"; shift 2 ;;
        -* ) log_error "Unknown option: $1"; usage ;;
        * )
            if [[ -z "$FROM" ]]; then FROM="$1"
            else TO="$1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$FROM" ]]; then
    log_error "At least one commit ID is required"
    echo "  Usage: release-summary <commit1> [commit2]"
    exit 1
fi

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not a Git repository. Run this inside any Git project."
    exit 1
fi

if ! git cat-file -e "$FROM" 2>/dev/null; then
    log_error "Invalid commit: $FROM"; exit 1
fi
if [[ "$TO" != "HEAD" ]] && ! git cat-file -e "$TO" 2>/dev/null; then
    log_error "Invalid commit: $TO"; exit 1
fi

log_info "Range: $FROM .. $TO"

RAW=$(git log "$FROM..$TO" --no-merges --format="%h %s (%an)" 2>/dev/null || true)

if [[ -z "$(echo "$RAW" | tr -d '[:space:]')" ]]; then
    echo "# Release Summary — No changes" > "$OUTPUT_FILE"
    log_info "No changes found. Generated: $OUTPUT_FILE"
    exit 0
fi

if [[ -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo '.')")
fi

TOTAL=$(echo "$RAW" | sed '/^$/d' | wc -l | tr -d ' ')
TODAY=$(date "+%Y-%m-%d")

# ---- AI 总结（claude CLI 可用时） ----
SUMMARY=""
if command -v claude &>/dev/null; then
    log_info "Generating AI summary via Claude..."
    PROMPT="Below is the output of \`git log $FROM..$TO --no-merges\`. Summarize the main functional changes in this release in concise bullet points (English or Chinese, match the commit message language). Group by feature area. No more than 15 bullets. Output summary only, no preamble.

\`\`\`
$RAW
\`\`\`"

    SUMMARY=$(echo "$PROMPT" | claude --print --output-format text 2>/dev/null || true)
fi

# ---- 生成 Markdown ----
{
    echo "# $PROJECT_NAME Release Summary"
    echo
    echo "> **Generated**: $TODAY"
    echo "> **Range**: \`$FROM .. $TO\`"
    echo "> **Commits**: $TOTAL"
    echo
    if [[ -n "$SUMMARY" ]]; then
        echo "## Highlights"
        echo
        echo "$SUMMARY"
        echo
    fi
    echo "## Commits"
    echo
    echo '```'
    echo "$RAW"
    echo '```'
    echo
    echo "> Full diff: \`git diff $FROM..$TO\`"
} > "$OUTPUT_FILE"

log_info "Generated: $OUTPUT_FILE ($TOTAL commits)"
