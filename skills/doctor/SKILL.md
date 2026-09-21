---
name: doctor
description: Health check for the docs/ai/ knowledge base — dangling sessions, broken links, orphan or duplicate identifiers, translated machine layer, stale or oversized files. Reports by default; pass --fix to apply the mechanical repairs. Invoke as /memento:doctor.
argument-hint: [--fix]
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Bash(git log:*)
  - Bash(git status:*)
---

Harness context:
- Argument: $ARGUMENTS
- Bundle root: `${CLAUDE_PLUGIN_ROOT}/skills/memento`

Follow `${CLAUDE_PLUGIN_ROOT}/skills/memento/references/doctor.md` in full.
Paths it writes as `references/...` or `assets/...` are relative to the bundle
root above.
