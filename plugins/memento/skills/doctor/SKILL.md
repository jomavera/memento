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

Mode: `$ARGUMENTS` — `--fix` applies mechanical repairs, anything else reports only.

Read `${CLAUDE_PLUGIN_ROOT}/reference/conventions.md` first. Every check below
tests a rule defined there; when a check and the conventions disagree, the
conventions win and the check is the bug.

If `docs/ai/` does not exist, say so, offer `/session-init`, and stop.

## Checks

Run all of them before reporting anything. Group findings by severity, not by
check.

### Broken — the framework or its reader will get the wrong answer

1. **Translated machine layer.** Any `status:` value outside
   `active | closed | abandoned`, any stage status outside
   `done | partial | failed | skipped | blocked`, or frontmatter keys that are
   not the ones in `templates/SESSION.md`. This is the failure §9 warns about:
   a session written `status: cerrado` stays invisible to `/session-start`
   forever. Check every session and ADR file. `config.yml` keys and values are
   part of this layer too — `profile:` must name only known profiles (§10).
2. **More than one `active` session.** Only one may be open at a time.
3. **Broken internal links.** Every relative markdown link inside `docs/ai/`
   must resolve to a file that exists.
4. **Identifier collisions.** Two sessions with the same `S` id, two learnings
   with the same `L-` id, two ADRs with the same number. Gaps are fine and
   expected — ids are never reused — but duplicates are not.
5. **Dangling supersession.** An ADR whose status names an `ADR-NNNN` that does
   not exist.
6. **Index and disk disagree.** A session file with no row in `INDEX.md`, a row
   pointing at no file, or a row whose status differs from the file's
   frontmatter. Same for ADRs against `decisions/README.md`.
7. **Cross-reference asymmetry.** A session's frontmatter lists `L-0007` but
   `LEARNINGS.md` has no such entry, or a learning links a session that does
   not exist.

### Stale — still readable, no longer trustworthy

8. **`PROJECT.md` uncurated.** `Last curated` more than 90 days old, or older
   than the last three closed sessions.
9. **Session stuck open.** An `active` session whose date is more than 2 days
   ago. Either it was never closed, or the record is wrong.
10. **Unanswered `TBD:`.** A `PROJECT.md` section still `TBD:` after five or
    more closed sessions — nobody is going to answer it by accident.
11. **Aging open question.** An entry under Open questions older than 6 months.

### Warning — budget and convention drift

12. **`PROJECT.md` over the ~200-line cap**, comments included (§3).
13. **`LEARNINGS.md` past ~150 lines**, the point where sessions stop reading it
    whole (§3).
14. **Slug not portable.** A file or folder name under `sessions/` or
    `decisions/` with accents, spaces, uppercase or non-Latin characters (§9).
15. **Filename and frontmatter disagree** on the id or the date.
16. **Session promoted but not linked.** A session folder whose `INDEX.md` link
    still points at the old flat `.md` path (§2).
17. **Closed session with an empty Handoff**, or one whose stages have no
    validation verdict recorded (§6).
18. **Unfailable checks.** A stage recorded `done` whose validation could not
    have come out otherwise — "reviewed", "looks correct", "ran without error"
    where the profile calls for agreement rather than execution (§6, §10). Report
    these; never rewrite them, since only the person who did the work knows what
    was actually verified.
19. **Sections missing for the active profile.** `PROJECT.md` lacking a section
    its profile contributes, allowing for the heading the file already uses (§9).

## Report

For each finding: the severity, the file and line, what rule it breaks, and the
concrete fix. Order by severity, then by file. Where a single cause produced
several findings, say so once rather than listing it seven times.

End with one line: how many findings in each severity, and whether `--fix`
would resolve any of them.

If everything passes, say so in one line and stop. Do not manufacture findings
to look useful — a clean knowledge base is the expected outcome, not a suspicious
one.

## Repair, only with `--fix`

Apply only repairs where exactly one correct outcome exists and no judgement is
involved:

- restore a missing `INDEX.md` or `decisions/README.md` row from the file's own
  frontmatter, and conversely correct a row that contradicts its file;
- fix a link whose target obviously moved, such as a promoted session folder;
- normalise a machine-layer value that was translated, when the intended English
  value is unambiguous;
- rename a non-portable slug, updating every link that points at it.

Never, even with `--fix`:

- close, abandon or reopen a session — status is a claim about reality, and only
  `/session-close` may make it;
- write or edit a learning, an ADR or any prose in `PROJECT.md`;
- delete anything;
- renumber identifiers, or fill a gap in a sequence.

Anything outside the mechanical list is reported with the fix described, for the
user to decide. Say explicitly what was repaired and what was left alone.
