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

Focus, if the user gave one: $ARGUMENTS

This command reports. It does not write, does not open a session, and does not
curate anything — `Write` and `Edit` are withheld for the duration so that
guarantee holds. If the briefing reveals work worth doing, say so and let the
user decide.

## 1. Gather

If `${CLAUDE_PROJECT_DIR}/docs/ai/` does not exist, say the repository has no
knowledge base yet, offer `/session-init`, and stop.

Otherwise read:

- `docs/ai/PROJECT.md` in full
- `docs/ai/sessions/INDEX.md` in full
- the newest closed session's **Handoff** section, and any `active` session
- `docs/ai/decisions/README.md`
- `docs/ai/LEARNINGS.md` — the most recent entries, or `grep` it for the focus
  terms when the user gave one

With a focus argument, widen selectively: open the specific sessions, ADRs and
learnings that touch it, and skip the rest. Without one, do not open individual
session logs at all — `INDEX.md` is what that file is for.

## 2. Report

Write the briefing to the terminal in the repository's document language
(conventions §9, in `${CLAUDE_PLUGIN_ROOT}/reference/conventions.md`). Aim for
something a person can read in under a minute:

1. **What this project is** — two lines, from `PROJECT.md`.
2. **Where it stands** — the last few sessions as one line each: what was
   attempted, and what came of it. Say plainly when something was not met.
3. **What is open** — unfinished threads from the newest handoff, plus open
   questions from `PROJECT.md`. This is usually the part the user actually
   wants; lead with it if they asked "what should I do next".
4. **What to know before touching it** — at most five items: the learnings and
   decisions that would change how someone approaches the work. Cite ids.
5. **Caveats** — if `Last curated` is more than about three months old, or a
   session has been `active` for days, or a section is still `TBD`, say so.
   Knowledge nobody has checked in a quarter should be read with suspicion, and
   the reader deserves to know that before acting on it.

Then, when anything in step 5 fired, mention `/memento:doctor` in one line.

## Judgement

Report what the knowledge base says, and mark anything you add from reading the
code as your own inference, not as recorded fact. Where the record is thin,
say it is thin — "three sessions, none touching this area" is a useful answer.
Do not fill silence with plausible-sounding summary; a briefing that invents
confidence is worse than no briefing.
