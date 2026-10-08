---
name: memento
description: A lean session framework that gives a coding agent memory across sessions. Opens and closes traceable work sessions, and distils what was learned into a versioned knowledge base under docs/ai/ — session logs, a project map, a learnings ledger and decision records. Use when opening or closing a work session, bootstrapping docs/ai/ in a repository, briefing on where a project stands, auditing the knowledge base, or answering how docs/ai/ is structured and what belongs in it.
license: MIT
metadata:
  author: jomavera
  version: "1.5.0"
  homepage: https://github.com/jomavera/memento-session
---

# Memento

A work session has an objective, stages with checks, and a record. Memento makes
that record durable: every session leaves a log, and what proves durable is
distilled into a knowledge base the next session reads before touching anything.

Everything lives in the **target repository** under `docs/ai/`, and everything is
committed. `references/conventions.md` is the single source of truth for layout,
identifiers and rules; where a procedure and the conventions disagree, the
conventions win and the procedure is the bug.

## The procedures

Run these, in this order, per unit of work:

| Procedure | When |
|---|---|
| `references/session-init.md` | Once per repository, to create `docs/ai/`. |
| `references/session-start.md` | Open a session: load the knowledge, agree the objective, plan the stages. |
| `references/session-close.md` | Verify each stage's check, finish the log, distil what is durable. |
| `references/project-brief.md` | Read-only briefing. Writes nothing. Any time. |
| `references/doctor.md` | Audit the knowledge base for stale or broken records. |

Read the procedure you need in full, then follow it. Do not summarise it from
this file — the detail is the point.

Opening and closing a session is a deliberate act. Never run `session-start` or
`session-close` on your own initiative: if substantial work is starting in a
repository that has `docs/ai/`, mention `session-start` once and let the user
decide. `project-brief` and `doctor` are safe to offer freely.

## The reference material

| File | What |
|---|---|
| `references/conventions.md` | Layout, identifiers, promotion tests, correlation, language rules, profiles. Read it before any procedure. |
| `references/profile-code.md` | What to survey and what counts as a check, for software work. |
| `references/profile-analysis.md` | The same, for data pipelines, models and metrics, where a validated check means reconciliation rather than a passing test. |
| `assets/` | The documents the framework creates: `SESSION.md`, `PROJECT.md`, `LEARNINGS.md`, `ADR.md`, `config.yml`, the index and README seeds, and `AGENTS-section.md`. |

All paths in this bundle are relative to the bundle root — the directory holding
this `SKILL.md`. There are no variables to substitute.

## Harness context

Some values a procedure needs are not part of this bundle because they differ by
harness: the user's argument, a default document language, a conversation id.
Whatever invokes a procedure supplies them as a short **harness context** block,
for example:

```
Harness context:
- Argument: cut the nightly load below 15 min
- Default document language: English
- Conversation id: abc123      (or: this harness exposes none)
```

Where a procedure says "the argument from the harness context" or "the default
from the harness context", that block is what it means. A value that is absent
is simply unset: fall back as the procedure says, and never write a literal
placeholder into a document.

If you are reading this skill directly, with no such block, treat every value as
unset — the argument is whatever the user just asked for, the document language
resolves from `docs/ai/config.yml` or defaults to English, and
`claude_session_ids` stays empty.

## Language

Instructions in this bundle are always English. The **documents the framework
generates** follow a configured language, English by default, resolved per
conventions §9. The machine layer — frontmatter keys, status values,
identifiers, file names, slugs — never gets translated, because the framework
reads it back.
