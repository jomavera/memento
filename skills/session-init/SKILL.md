---
name: session-init
description: Bootstrap Memento in this repository — create the docs/ai/ knowledge base, set the document language, and seed PROJECT.md from what the repository already documents. Run once per repository.
argument-hint: [document language, default English]
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
  - Bash(git branch:*)
---

Harness context:
- Argument: $ARGUMENTS
- Default document language: ${user_config.document_language}
- Bundle root: `${CLAUDE_PLUGIN_ROOT}/skills/memento`

Follow `${CLAUDE_PLUGIN_ROOT}/skills/memento/references/session-init.md` in full.
Paths it writes as `references/...` or `assets/...` are relative to the bundle
root above. Ignore a context value that arrives empty or still reads as a literal
`${...}` placeholder — that means the harness did not substitute it.
