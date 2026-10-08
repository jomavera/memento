---
name: session-start
description: Open a traceable work session — load the accumulated project knowledge, agree one objective with the user, plan the stages, and create the session log under docs/ai/sessions/.
argument-hint: [objective in one sentence]
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
- Conversation id: ${CLAUDE_SESSION_ID}
- Bundle root: `${CLAUDE_PLUGIN_ROOT}/skills/memento`

Follow `${CLAUDE_PLUGIN_ROOT}/skills/memento/references/session-start.md` in full.
Paths it writes as `references/...` or `assets/...` are relative to the bundle
root above. Ignore a context value that arrives empty or still reads as a literal
`${...}` placeholder — that means the harness did not substitute it.

Where the procedure asks you to put concrete alternatives to the user, you have
`AskUserQuestion`; use it rather than an open question.
