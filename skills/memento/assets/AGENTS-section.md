<!-- memento:begin -->
## AI session knowledge base

Accumulated knowledge for this repository lives in `docs/ai/` and is versioned:

- `docs/ai/PROJECT.md` — current map of this project. Read before non-trivial work.
- `docs/ai/LEARNINGS.md` — non-obvious discoveries from past sessions.
- `docs/ai/decisions/` — decision records. Read the ones governing the area you touch.
- `docs/ai/sessions/INDEX.md` — what each past session attempted and what came of it.
- `docs/ai/config.yml` — settings, including the language these documents are written in.

Run `/session-start` before substantial work and `/session-close` before ending
it. If substantial work begins without an open session, mention it once and
offer `/session-start`; do not insist.

Write these documents in the language set in `docs/ai/config.yml`, matching the
headings already present. Frontmatter keys, status values, identifiers, file
names and slugs stay in English — the framework reads those back.

Only `/session-close` writes to `PROJECT.md`, `LEARNINGS.md` or `decisions/`.
A closed session log is immutable — correct the record in a new session.
<!-- memento:end -->
