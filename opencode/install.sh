#!/usr/bin/env bash
#
# Install Memento for opencode.
#
# skills/memento/ is a canonical Agent Skills bundle (agentskills.io): every
# path inside it is relative to the bundle root and there are no variables to
# substitute. So it copies across verbatim — this script ports nothing.
#
# What differs by harness is supplied as a short "harness context" block, which
# is all these generated commands are: five thin wrappers around the procedures
# in the bundle. The Claude Code plugin does the same thing in skills/<name>/.
#
# Writes:
#   <config>/skill/memento/     the bundle, verbatim
#   <config>/command/<name>.md  one thin wrapper per procedure
#   <config>/agent/memento-brief.md
#
# <config> is $OPENCODE_CONFIG_DIR, else ~/.config/opencode. Note that this is
# NOT ~/.opencode, which opencode ignores for configuration.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_SRC="$SRC/skills/memento"
LANGUAGE="English"
CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
DRY_RUN=0

# Claude Code skill directory : opencode command name. opencode commands are
# flat, so the /memento:doctor namespace collapses to a prefixed name.
COMMANDS=(
  "session-init:session-init"
  "session-start:session-start"
  "session-close:session-close"
  "project-brief:project-brief"
  "doctor:memento-doctor"
)

agent_for() {
  case "$1" in
    project-brief) echo "memento-brief" ;;
    *) echo "" ;;
  esac
}

# Values the bundle cannot know. Keep in step with the wrappers in skills/.
harness_context() {
  local skill="$1" bundle="$2"
  echo "Harness context:"
  echo "- Argument: \$ARGUMENTS"
  case "$skill" in
    session-init|session-start|session-close)
      echo "- Default document language: $LANGUAGE" ;;
  esac
  if [ "$skill" = "session-start" ]; then
    echo "- Conversation id: opencode exposes none to a command, so leave"
    echo "  \`claude_session_ids\` empty (conventions §8)"
  fi
  echo "- Bundle root: \`$bundle\`"
}

usage() {
  cat <<'EOF'
Usage: opencode/install.sh [options]

  --language NAME     Default language for generated documents (default: English).
                      A repository's docs/ai/config.yml still overrides it.
  --config-dir PATH   opencode config directory
                      (default: $OPENCODE_CONFIG_DIR, else ~/.config/opencode).
  --dry-run           Verify everything, but write nothing.
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
GENERATED=()

# ---------------------------------------------------------------------------
# Verify the bundle before installing it
#
# The bundle's portability is the whole design, and it rests on one invariant:
# no harness-specific interpolation anywhere inside it. Check that here, so a
# regression upstream fails the install instead of shipping a bundle whose
# paths silently do not resolve.
# ---------------------------------------------------------------------------
[ -f "$BUNDLE_SRC/SKILL.md" ] || { echo "missing bundle: $BUNDLE_SRC/SKILL.md" >&2; exit 1; }

if grep -rlE '\$\{[A-Za-z_]' "$BUNDLE_SRC" > /dev/null 2>&1; then
  echo "verify: the bundle contains a harness-specific interpolation:" >&2
  grep -rnE '\$\{[A-Za-z_]' "$BUNDLE_SRC" | sed 's|^|  |' >&2
  echo "        skills/memento/ must stay free of variables — that is what makes" >&2
  echo "        it portable. Move the value into the harness context instead." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

# The bundle is disposable; rebuild it so an upstream deletion cannot linger.
if [ "$DRY_RUN" -eq 0 ] && [ -d "$BUNDLE" ]; then
  rm -rf "$BUNDLE"
fi

while IFS= read -r rel; do
  GENERATED+=("$BUNDLE/$rel")
  [ "$DRY_RUN" -eq 1 ] && continue
  mkdir -p "$(dirname "$BUNDLE/$rel")"
  cp "$BUNDLE_SRC/$rel" "$BUNDLE/$rel"
done < <(cd "$BUNDLE_SRC" && find . -type f | sed 's|^\./||' | sort)

for entry in "${COMMANDS[@]}"; do
  skill="${entry%%:*}"
  command="${entry##*:}"
  src="$SRC/skills/$skill/SKILL.md"
  out="$CONFIG_DIR/command/$command.md"

  [ -f "$src" ] || { echo "missing wrapper source: $src" >&2; exit 1; }

  # The description lives in the Claude Code wrapper, so both builds describe
  # each command with the same sentence.
  description="$(awk '/^---$/ {n++; next} n==1 && /^description:/ {sub(/^description:[[:space:]]*/, ""); print; exit}' "$src" |
    sed -e 's|/memento:doctor|/memento-doctor|g')"
  [ -n "$description" ] || { echo "no description in $src" >&2; exit 1; }

  agent="$(agent_for "$skill")"
  GENERATED+=("$out")
  [ "$DRY_RUN" -eq 1 ] && continue

  mkdir -p "$(dirname "$out")"
  {
    echo "---"
    echo "description: $description"
    [ -n "$agent" ] && echo "agent: $agent"
    echo "---"
    echo
    harness_context "$skill" "$BUNDLE"
    echo
    echo "Follow \`$BUNDLE/references/$skill.md\` in full. Paths it writes as"
    echo "\`references/...\` or \`assets/...\` are relative to the bundle root above."
    if [ "$skill" = "project-brief" ]; then
      echo
      echo "This reports and never writes; the \`memento-brief\` agent withholds the"
      echo "write, edit and patch tools so that guarantee holds structurally."
    fi
  } > "$out"
done

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
# Report
# ---------------------------------------------------------------------------
if [ "$DRY_RUN" -eq 1 ]; then
  echo "would write ${#GENERATED[@]} files under $CONFIG_DIR"
else
  echo "wrote ${#GENERATED[@]} files under $CONFIG_DIR"
  echo
  echo "Bundle: $BUNDLE (re-run this script after editing skills/memento/)"
  echo "Document language: $LANGUAGE (a repository's docs/ai/config.yml overrides it)"
  echo -n "Restart opencode, then: "
  for entry in "${COMMANDS[@]}"; do printf '/%s ' "${entry##*:}"; done
  echo
fi
