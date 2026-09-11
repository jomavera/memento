#!/usr/bin/env bash
#
# Generate an opencode build of Memento from the Claude Code plugin source.
#
# The plugin is the single source of truth. This script writes:
#
#   <config>/skill/memento/SKILL.md      bundle entry point
#   <config>/skill/memento/reference/    conventions and profiles
#   <config>/skill/memento/templates/    document templates
#   <config>/command/<name>.md           one opencode command per skill
#   <config>/agent/memento-brief.md      read-only agent behind /project-brief
#
# <config> is $OPENCODE_CONFIG_DIR, else ~/.config/opencode. Note that this is
# NOT ~/.opencode, which opencode ignores for configuration.
#
# reference/ and templates/ go inside a skill folder because that is opencode's
# only native home for resource files: its skill loader lists every file under a
# skill's directory and hands the model that list along with the directory path.
# Commands have no bundling mechanism of their own, so they point into it.
#
# Everything under <config>/skill/memento is a build artifact. Edit the plugin
# source and re-run this script; never edit the installed copy, and re-run after
# changing reference/ or templates/ or the two will drift.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LANGUAGE="English"
CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
DRY_RUN=0

# skill directory : opencode command name. opencode commands are flat, so the
# /memento:doctor namespace collapses to a prefixed name.
COMMANDS=(
  "session-init:session-init"
  "session-start:session-start"
  "session-close:session-close"
  "project-brief:project-brief"
  "doctor:memento-doctor"
)

# Commands that must run under a restricted agent rather than the default one.
agent_for() {
  case "$1" in
    project-brief) echo "memento-brief" ;;
    *) echo "" ;;
  esac
}

usage() {
  cat <<'EOF'
Usage: opencode/install.sh [options]

  --language NAME     Default language for generated documents (default: English).
                      A repository's docs/ai/config.yml still overrides it.
  --config-dir PATH   opencode config directory
                      (default: $OPENCODE_CONFIG_DIR, else ~/.config/opencode).
  --dry-run           Port and verify everything, but write nothing.
  -h, --help          Show this message.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --language)   [ $# -ge 2 ] || { echo "--language needs a value" >&2; exit 2; }
                  LANGUAGE="$2"; shift 2 ;;
    --config-dir) [ $# -ge 2 ] || { echo "--config-dir needs a value" >&2; exit 2; }
                  CONFIG_DIR="$2"; shift 2 ;;
    --dry-run)    DRY_RUN=1; shift ;;
    -h|--help)    usage; exit 0 ;;
    *)            echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

BUNDLE="$CONFIG_DIR/skill/memento"

# sed replacement text treats & as "the whole match", and | is our delimiter.
esc() { printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'; }
BUNDLE_ESC="$(esc "$BUNDLE")"
LANGUAGE_ESC="$(esc "$LANGUAGE")"

# ---------------------------------------------------------------------------
# Porting
#
# Every divergence that needed a *semantic* rewrite was resolved upstream: the
# plugin source names both harnesses where they genuinely differ (conventions
# §8 on claude_session_ids), and reference/ and templates/ carry no
# harness-specific vocabulary at all, so they copy across untouched. What is
# left is mechanical, and every rule below is a single-line substitution
# applied only to skill files.
# ---------------------------------------------------------------------------
port() {
  sed \
    -e "s|\${CLAUDE_PLUGIN_ROOT}|$BUNDLE_ESC|g" \
    -e "s|\${CLAUDE_PROJECT_DIR}/||g" \
    -e "s|\${user_config.document_language}|$LANGUAGE_ESC|g" \
    -e "s|/memento:doctor|/memento-doctor|g" \
    -e "s|CLAUDE\.md|AGENTS.md|g" \
    "$1"
}

GENERATED=()

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

# The bundle is disposable. Rebuild it from scratch so that a file deleted
# upstream cannot linger here as a stale instruction.
if [ "$DRY_RUN" -eq 0 ] && [ -d "$BUNDLE" ]; then
  rm -rf "$BUNDLE"
fi

# The bundle entry point, written for opencode by hand.
bundle_skill="$SRC/opencode/skill/memento/SKILL.md"
[ -f "$bundle_skill" ] || { echo "missing bundle source: $bundle_skill" >&2; exit 1; }
GENERATED+=("$BUNDLE/SKILL.md")
if [ "$DRY_RUN" -eq 0 ]; then
  mkdir -p "$BUNDLE"
  cp "$bundle_skill" "$BUNDLE/SKILL.md"
fi

# reference/ and templates/ are harness-neutral, so they copy verbatim. The
# verify pass below is what keeps that true.
while IFS= read -r rel; do
  GENERATED+=("$BUNDLE/$rel")
  [ "$DRY_RUN" -eq 1 ] && continue
  mkdir -p "$(dirname "$BUNDLE/$rel")"
  cp "$SRC/$rel" "$BUNDLE/$rel"
done < <(cd "$SRC" && find reference templates -type f | sort)

# One opencode command per skill.
for entry in "${COMMANDS[@]}"; do
  skill="${entry%%:*}"
  command="${entry##*:}"
  src="$SRC/skills/$skill/SKILL.md"
  out="$CONFIG_DIR/command/$command.md"

  [ -f "$src" ] || { echo "missing skill source: $src" >&2; exit 1; }

  ported="$(port "$src")"
  description="$(printf '%s\n' "$ported" |
    awk '/^---$/ {n++; next} n==1 && /^description:/ {sub(/^description:[[:space:]]*/, ""); print; exit}')"
  [ -n "$description" ] || { echo "no description in $src" >&2; exit 1; }

  # opencode command frontmatter accepts only description/agent/model/variant/
  # subtask. The skill's allowed-tools, disallowed-tools, argument-hint and
  # disable-model-invocation have no opencode equivalent and are dropped; see
  # opencode/README.md for what that costs and how it is compensated.
  body="$(printf '%s\n' "$ported" | awk 'BEGIN {n = 0} /^---$/ && n < 2 {n++; next} n == 2 {print}')"
  agent="$(agent_for "$skill")"

  GENERATED+=("$out")
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$(dirname "$out")"
    {
      echo "---"
      echo "description: $description"
      [ -n "$agent" ] && echo "agent: $agent"
      echo "---"
      printf '%s\n' "$body"
    } > "$out"
  fi
done

# Agents are written for opencode by hand, not ported, so they are copied as-is.
for entry in "${COMMANDS[@]}"; do
  agent="$(agent_for "${entry%%:*}")"
  [ -n "$agent" ] || continue
  src="$SRC/opencode/agent/$agent.md"
  [ -f "$src" ] || { echo "missing agent source: $src" >&2; exit 1; }
  out="$CONFIG_DIR/agent/$agent.md"
  GENERATED+=("$out")
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$(dirname "$out")"
    cp "$src" "$out"
  fi
done

# ---------------------------------------------------------------------------
# Verify
#
# A Claude-only construct reaching the installed tree is a silent failure: the
# model would read a literal ${...} as a path, or reach for a tool that does not
# exist here. Fail the build instead of shipping it.
#
# ${CLAUDE_SESSION_ID} is deliberately absent from this list. The two passages
# that use it name Claude Code explicitly and tell any other harness to leave
# claude_session_ids empty, so they are correct here unported.
# ---------------------------------------------------------------------------
if [ "$DRY_RUN" -eq 0 ]; then
  failures=0
  patterns=(
    '\${CLAUDE_PLUGIN_ROOT}'
    '\${CLAUDE_PROJECT_DIR}'
    '\${user_config\.'
    'AskUserQuestion'
    '/memento:'
  )
  for out in "${GENERATED[@]}"; do
    for pattern in "${patterns[@]}"; do
      if grep -qE "$pattern" "$out"; then
        echo "verify: unported construct '$pattern' in $out" >&2
        failures=$((failures + 1))
      fi
    done
    # CLAUDE.md is where the memento block goes under Claude Code and AGENTS.md
    # under opencode — except in the profiles, which name CLAUDE.md as a file to
    # go looking for when surveying a repository. That is still correct here.
    case "$out" in
      */reference/profiles/*) ;;
      *) if grep -qE 'CLAUDE\.md' "$out"; then
           echo "verify: unported construct 'CLAUDE.md' in $out" >&2
           failures=$((failures + 1))
         fi ;;
    esac
  done

  if [ "$failures" -gt 0 ]; then
    echo "install failed: $failures problem(s); the plugin source grew something this script does not know how to port." >&2
    exit 1
  fi
fi

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
if [ "$DRY_RUN" -eq 1 ]; then
  echo "would write ${#GENERATED[@]} files under $CONFIG_DIR"
else
  echo "wrote ${#GENERATED[@]} files under $CONFIG_DIR"
fi
printf '  %s\n' "${GENERATED[@]}"

if [ "$DRY_RUN" -eq 0 ]; then
  echo
  echo "Bundle: $BUNDLE (re-run this script after editing reference/ or templates/)"
  echo "Document language: $LANGUAGE (a repository's docs/ai/config.yml overrides it)"
  echo -n "Restart opencode, then: "
  for entry in "${COMMANDS[@]}"; do printf '/%s ' "${entry##*:}"; done
  echo
fi
