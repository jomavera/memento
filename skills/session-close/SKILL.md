---
name: session-close
description: Close the open work session — verify each stage's check, finish the session log, distill durable learnings and decisions into the project knowledge base, and update the traceability index.
argument-hint: (no arguments)
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash(git status:*)
  - Bash(git rev-parse:*)
  - Bash(git log:*)
  - Bash(git diff:*)
  - Bash(git branch:*)
---

Harness context:
- Argument: $ARGUMENTS
- Default document language: ${user_config.document_language}
- Bundle root: `${CLAUDE_PLUGIN_ROOT}/skills/memento`

Follow `${CLAUDE_PLUGIN_ROOT}/skills/memento/references/session-close.md` in full.
Paths it writes as `references/...` or `assets/...` are relative to the bundle
root above. Ignore a context value that arrives empty or still reads as a literal
`${...}` placeholder — that means the harness did not substitute it.
