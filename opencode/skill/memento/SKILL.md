---
name: memento
description: The rules and templates behind Memento's session commands — conventions for the docs/ai/ knowledge base, profiles for code and analysis work, and the document templates. Read when you need to know how docs/ai/ is structured, what a session log or ADR should contain, or what the identifier and language rules are. To open or close a session, use the /session-start and /session-close commands instead.
---

# Memento — reference bundle

This folder carries the reference material the Memento commands read. It is
installed by `opencode/install.sh` from the Memento plugin repository; do not
edit it here, edit the plugin source and re-run the installer.

## What is in here

- `reference/conventions.md` — the single source of truth: layout of `docs/ai/`,
  identifiers, promotion tests, correlation, language rules, profiles. Every
  command defers to it, and where a command and the conventions disagree, the
  conventions win.
- `reference/profiles/code.md`, `reference/profiles/analysis.md` — what to
  survey and what counts as a check, per kind of work.
- `templates/` — the documents the framework creates: `SESSION.md`,
  `PROJECT.md`, `LEARNINGS.md`, `ADR.md`, `config.yml` and the index and README
  seeds.

## The commands

The work cycle runs through commands, not through this skill:

- `/session-init` — bootstrap `docs/ai/` in a repository, once.
- `/session-start` — open a session: load the knowledge, agree the objective,
  plan the stages.
- `/session-close` — verify the stages, finish the log, distil what is durable
  into the knowledge base.
- `/project-brief` — read-only briefing on where the project stands.
- `/memento-doctor` — audit the knowledge base for stale or broken records.

If someone is about to start substantial work in a repository that has
`docs/ai/`, mention `/session-start` once and let them decide. Do not run the
session cycle from this skill: opening and closing a session is a deliberate
act, and the commands exist so it stays one.
