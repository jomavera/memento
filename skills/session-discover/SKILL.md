---
name: session-discover
description: Design a project from scratch — align on the problem and scope, evaluate the options, and record the approved design in docs/ai/DESIGN.md to seed PROJECT.md. Greenfield entry point; use instead of session-init when there is no code yet.
argument-hint: [the idea to design, in one sentence]
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - Bash(git status:*)
  - Bash(git rev-parse:*)
  - Bash(git log:*)
  - Bash(git branch:*)
---

Harness context:
- Argument: $ARGUMENTS
- Default document language: ${user_config.document_language}
- Bundle root: `${CLAUDE_PLUGIN_ROOT}/skills/memento`

Follow `${CLAUDE_PLUGIN_ROOT}/skills/memento/references/session-discover.md` in full.
Paths it writes as `references/...` or `assets/...` are relative to the bundle
root above. Ignore a context value that arrives empty or still reads as a literal
`${...}` placeholder — that means the harness did not substitute it.

Where the procedure asks you to put concrete alternatives to the user, you have
`AskUserQuestion`; use it rather than an open question.
