---
name: session-close
description: Close the open work session — verify each stage's check, finish the session log, distill durable learnings and decisions into the project knowledge base, and update the traceability index.
argument-hint: (no arguments)
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
  - Bash(git diff:*)
  - Bash(git branch:*)
---

Read `${CLAUDE_PLUGIN_ROOT}/reference/conventions.md` if it is not already in
context. §5 (promotion tests) governs everything below.

Find the `active` session in `docs/ai/sessions/`. If there is none, say so and
offer `/session-start` — do not invent a log after the fact.

Read `docs/ai/config.yml`. Everything written below goes in this repository's
document language (conventions §9): that file, else
`${user_config.document_language}`, else English — but the language of the
documents already on disk wins, so a knowledge base never ends up
half-translated. In existing files, match the headings already there instead of
re-translating from the template, and leave the machine layer in English.

The same file gives the profile (§10, default `[code]`). Read
`${CLAUDE_PLUGIN_ROOT}/reference/profiles/<name>.md` for each active one: it
defines what a valid check looks like when you verify the stages below, and
which sections `PROJECT.md` is supposed to carry.

## Phase 1 — Verify, don't assert

Go stage by stage through the log:

- Did that stage's check actually run in this session? If yes, restate the
  verdict you observed. If no, mark it `skipped` and say why.
- Where a check is cheap and repeatable, **re-run it now** — the commands in
  `PROJECT.md`, and for an `analysis` project the reconciliation queries. A green
  run at close is worth more than a green run from twenty turns ago, before three
  more stages of changes. Record the figures the re-run produced, not that it
  passed.
- Report failures as failures, with the output. Do not soften, do not defer.

Then state, in one line, whether the session's **done when** conditions are met:
`met` · `partially met` · `not met`. If they are not met, the session status is
`abandoned`, not `closed`. Say which condition failed and what would resolve it.

Never adjust the objective or the done-when conditions to match the outcome.

## Phase 2 — Finish the log

In the session file:

- Fill the **Results** section: what now exists that did not before, and what
  changed, by path. Not a diff — the diff is in git. Two to six lines.
- Fill the **Validation** section: the checks that ran and their verdicts.
- Fill **Handoff**: what the next session needs. Open threads, known-broken
  things, deliberate non-goals, and the single most useful next step. This is
  the section a future session reads first — make it specific enough to act on.
- Set `status` to `closed` or `abandoned`, and `closed` to today's date.
- If the repository is a git repository, record `end_commit` and the commits
  this session produced.
- Promote the file to a folder if the conventions §2 thresholds are met.

## Phase 3 — Distill

Collect every `→ LEARNING:`, `→ DECISION:` and `→ PROJECT:` flag from the log,
plus anything that should have been flagged and was not. Then run each candidate
through the promotion tests in conventions §5. Be strict here — this is where a
knowledge base is either kept sharp or turned into landfill.

**Learnings.** For each survivor, `grep` `LEARNINGS.md` for its subject first.
If a similar entry exists, sharpen that entry instead of adding a near-duplicate.
Otherwise append a new entry in the template's format, with the next `L-` id and
a link back to this session. Expect zero to three. Zero is a normal, honest
result for a session that only executed a known plan.

**Decisions.** For each survivor, write
`docs/ai/decisions/ADR-<NNNN>-<slug>.md` from
`${CLAUDE_PLUGIN_ROOT}/templates/ADR.md`, and add its line to
`decisions/README.md`. The **Alternatives** section is the point of an ADR: name
what was rejected and why, or the record is worthless in six months. If this
session contradicts an existing ADR, do not edit that ADR — write a new one and
set the old one's status to `Superseded by ADR-<NNNN>`.

**PROJECT.md.** Edit only the facts that actually changed. Where you add a line,
look for a stale one to remove — the ~200-line cap is a budget, not a target.
Update the `Last curated` footer. If nothing durable changed, write nothing and
say "no durable change to PROJECT.md" in the report.

## Phase 4 — Update the index

Update this session's row in `docs/ai/sessions/INDEX.md`: final status, the
one-line outcome, and the ids of the learnings and ADRs it produced. The index
is the only place a human sees the whole history at a glance; keep the outcome
column honest and short.

## Phase 5 — Report

Give the user, compactly:

1. **Outcome** — objective met / partially met / not met, in one line.
2. **What changed** — deliverables by path.
3. **Verification** — checks run and their verdicts, failures included.
4. **Knowledge captured** — new `L-` and `ADR-` ids with their one-line claims,
   or explicitly "none, and why".
5. **Next step** — the handoff line.
6. **Commit** — the command, e.g.
   `git add docs/ai && git commit -m "Close S007: <outcome>"`.
   Offer it; do not run it unless the user asks.

Then confirm the session is closed. The log is now immutable — a later
correction goes in a new session, per conventions §4.7.
