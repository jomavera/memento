---
name: project-brief
description: Read-only briefing on where this project stands — what it is, what recent sessions did, what is still open, and what to know before touching it. Writes nothing.
when_to_use: When someone asks what this project is, where it stands, what has been happening in it, or what they should know before starting work — and when picking up a repository after time away. Not a substitute for /session-start, which opens a session.
argument-hint: [optional area or question to focus on]
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(git log:*)
  - Bash(git status:*)
disallowed-tools:
  - Write
  - Edit
  - NotebookEdit
---

Harness context:
- Argument: $ARGUMENTS
- Bundle root: `${CLAUDE_PLUGIN_ROOT}/skills/memento`

Follow `${CLAUDE_PLUGIN_ROOT}/skills/memento/references/project-brief.md` in full.
Paths it writes as `references/...` or `assets/...` are relative to the bundle
root above.

This reports and never writes; `Write` and `Edit` are withheld for the duration
so that guarantee holds structurally.
