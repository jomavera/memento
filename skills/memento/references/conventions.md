# Memento — conventions

Single source of truth for layout, identifiers and rules. `/session-init`,
`/session-start` and `/session-close` all defer to this file.

## 1. Layout

Everything lives in the **target repository** (the one being worked on), under
`docs/ai/`, and everything is **committed**. Never add `docs/ai/` to `.gitignore`.

```
docs/ai/
├── config.yml                          Per-repository framework settings (§9).
├── PROJECT.md                          Curated map of the project as it is now.
├── DESIGN.md                           Approved design, only when seeded by
│                                       `/session-discover` on a greenfield project.
├── LEARNINGS.md                        Append-only ledger of durable discoveries.
├── decisions/
│   ├── README.md                       One-line index of the ADRs.
│   └── ADR-0001-use-duckdb-for-staging.md
└── sessions/
    ├── INDEX.md                        Traceability table, newest first.
    ├── 2026-09-04-S001-refactor-etl.md         default form: one file
    └── 2026-09-06-S003-migrate-warehouse/      promoted form: one folder
        ├── SESSION.md
        └── assets/
```

### The two kinds of knowledge

| | Session knowledge | Project knowledge |
|---|---|---|
| Lives in | `sessions/` | `PROJECT.md`, `LEARNINGS.md`, `decisions/` |
| Scope | One objective, one point in time | The project as a whole, across sessions |
| Mutability | Frozen once closed | Curated and rewritten as reality changes |
| Answers | "What happened in S007 and why?" | "What do I need to know before touching this?" |

`/session-close` is the bridge between them: it distills session knowledge
into project knowledge. `/session-init` creates the empty structure and
`/session-discover` seeds it from an approved design. Nothing else writes to
`PROJECT.md`, `DESIGN.md` or `LEARNINGS.md` —
`/project-brief` only reads, and the doctor command repairs structure but never
content.

### Which file does a fact belong in?

Ask "how long will this stay true?"

- **True now, and a future session needs it before acting** → `PROJECT.md`.
- **A dated discovery whose value is the surprise it removes** → `LEARNINGS.md`.
- **A choice that closed off a real alternative** → an ADR.
- **Only meaningful as part of this session's story** → the session log, nothing else.

A fact never goes in two places. `PROJECT.md` wins; the other file links to it.

## 2. Identifiers

| Thing | Format | Assignment |
|---|---|---|
| Session | `S` + 3 digits (`S001`) | Highest existing number in `sessions/INDEX.md`, plus one. No index → `S001`. |
| Session file | `YYYY-MM-DD-S<NNN>-<slug>.md` | Date the session opened; `<slug>` is 2–4 kebab-case words from the objective. |
| Learning | `L-` + 4 digits (`L-0007`) | Highest existing in `LEARNINGS.md`, plus one. |
| Decision | `ADR-` + 4 digits (`ADR-0003`) | Highest existing in `decisions/`, plus one. |

Identifiers are never reused or renumbered, including for abandoned sessions.
Cross-reference by identifier plus a relative markdown link, so both a human and
a `grep` can follow the trail.

### Promotion from file to folder

A session starts as a single `.md`. Convert it to a folder with `SESSION.md`
(plus `assets/` if needed) when any of these becomes true:

- there are attachments worth keeping (logs, query output, screenshots, data samples);
- the log passes ~400 lines;
- there are more than 7 stages.

On promotion, move the file to `<same-name>/SESSION.md` and fix the `INDEX.md` link.

## 3. Context budget

`PROJECT.md` is read at the start of every session, so its size is a recurring
cost paid forever.

- **`PROJECT.md`: hard cap ~200 lines**, comments included. At the cap, prune
  before adding. Prefer deleting a stale fact over appending a fresh one.
- **`LEARNINGS.md`: read in full while under ~150 lines.** Past that, read the
  most recent 20 entries and `grep` the rest for terms from the objective.
- **Session logs: never bulk-read.** Read `INDEX.md`, then open at most the two
  or three logs whose objectives touch the current one.

Verbosity is not thoroughness. A knowledge base nobody can afford to load is a
knowledge base nobody reads.

## 4. Writing rules

These apply to every file this framework produces.

1. **Write for the next reader, not for the record.** There are two: an agent
   with no memory of this conversation, and a person who will read this months
   from now — a colleague inheriting the repository, or you, having forgotten.
   Give them what changes what they do; drop what merely proves work happened.
   Where the two audiences pull apart, the human wins on *form* (ordering,
   headings, plain language) and the agent wins on *precision* (exact commands,
   paths, verbatim errors). They rarely conflict on substance.
2. **Never restate what git already records.** No diffs, no file listings, no
   "renamed X to Y". Link the commit and write down the *why*.
3. **Never fabricate validation.** A stage is `done` only if its check actually
   ran and passed. Not run → `skipped`, with the reason. Ran and failed →
   `failed`, with the output. An honest `failed` is worth more than a false `done`.
4. **Evidence over adjectives.** "Query time 8.2 s → 0.4 s (`EXPLAIN` in
   `assets/plan.txt`)" beats "much faster".
5. **Record deviations, don't hide them.** Plans change; a plan silently edited
   to match the outcome destroys the log's value. Add, drop or reorder stages
   explicitly, each with a one-line why.
6. **Mark uncertainty as uncertainty.** Unverified facts are prefixed `TBD:` or
   `Assumed:`. Never promote a guess to a stated fact to make a document look
   complete.
7. **Closed logs are immutable.** Found an error in a closed session? Correct it
   in the current session's log and in the project knowledge, and note the
   supersession. Never rewrite history.
8. **Write in the configured language**, per §9. English by default, and the
   machine layer listed there stays English regardless.
9. **Content first, machinery in comments.** A reader opening any of these files
   must reach real content in the first few lines. Instructions about how the
   file is maintained go in `<!-- HTML comments -->`, which render invisible in
   GitHub, editors and previews while staying readable to an agent that opens
   the file. Keep those reminders to a couple of lines pointing at this
   document — never restate the rules, or they drift out of sync with it.

## 5. Promotion tests

The failure mode of every knowledge base is indiscriminate accumulation. Apply
these tests before writing.

**A learning** (`LEARNINGS.md`) must pass all three:

- **Non-obvious** — it wasn't inferable from the code, the README or the docs.
- **Recurring** — it will apply again, to a different task in this project.
- **Actionable** — it names something to *do* or *avoid*, not just something observed.

One-off incidents, restatements of documentation, and "we fixed bug X" all fail.
Two or three learnings per session is a lot. Zero is a perfectly normal result.

**A decision** (ADR) must pass both:

- a genuine alternative existed and was rejected;
- reversing it later would cost real work.

Choices with no alternative are just facts — they belong in `PROJECT.md`.

**A `PROJECT.md` edit** is warranted only when a durable fact about the project
actually changed: new component, changed command, new external dependency,
constraint discovered or lifted, question answered. If nothing changed, say
"no durable change" and edit nothing. Padding `PROJECT.md` to look productive is
the single most expensive mistake in this framework.

## 6. Stage records

A stage is a unit of work with one deliverable and one way to check it. Aim for
3–7 stages per session; more than that usually means the objective is two
objectives.

**A check must be able to fail.** Before recording one, name what would have
made it come out the other way. "Reviewed it" is not a check — nothing about it
could have failed. "Traced five records to the ERP; all five matched" is, because
they might not have. What counts as a check in this project comes from its
profile (§10).

Each stage record carries, in 3–8 lines:

- **Status** — `done` · `partial` · `failed` · `skipped` · `blocked`
- **Result** — the deliverable, and what changed, by path
- **Validation** — the exact check that ran, and its verdict
- **Notes** — only surprises, blockers or things a future session must know

Write a stage's record when the stage ends, not at close time. A context window
that runs out mid-session must not take the record with it.

## 7. Session status

| Status | Meaning |
|---|---|
| `active` | Open. At most one session may be `active` per repository. |
| `closed` | Ran through `/session-close`. Frozen. |
| `abandoned` | Ended without completing the objective. Records what was learned and why it stopped. |

An `abandoned` session is a legitimate outcome and still gets closed properly —
a dead end that nobody documented gets walked into twice.

## 8. Correlation — git, and the conversations behind the log

Where the target repository is a git repository, record in the session
frontmatter: `branch`, `base_commit` (HEAD at open), `end_commit` (HEAD at
close), and the commits the session produced. This is what ties a narrative
objective to the actual code change.

If git is unavailable or the commands fail, omit those fields and continue. The
framework must work in a non-git directory; it just loses this correlation.

`claude_session_ids` is a list, because a session may outlive several
conversations (§6). `/session-start` seeds it at open and appends on every
resume, newest last, using whatever conversation id the harness exposes. It
exists for one job: when a conversation dies mid-stage, the record for the stage
in flight was never written, and reopening that conversation — `claude --resume`
on the last id under Claude Code — is the only way to recover what was underway.

Treat it as a **local recovery aid, not part of the knowledge base.** Unlike
everything else under `docs/ai/`, it does not travel — transcripts live on one
machine and expire after a retention period. An id that resolves to nothing on
someone else's clone is expected, not corruption. Nothing in the framework reads
this field back; no check depends on it.

A harness that exposes no conversation id to a command — opencode is one —
leaves the list empty. The field keeps its name in every build so that one
knowledge base can be worked on from either harness without a schema conflict;
there, the per-stage records are the only recovery path.

Never commit on the user's behalf unless they ask. At close, report the paths
that changed and offer the command.

## 9. Language

Skill instructions and this reference are always in English. The **documents the
framework generates** follow a configured language, English by default.

### Resolution order

1. A language the user names for the work at hand.
2. `language:` in the target repository's `docs/ai/config.yml`.
3. The default document language given in the harness context, if any.
4. English.

`/session-init` writes (2), so a preference stated once holds for every later
session in that repository. Treat (3) as unset if it arrives empty or still
reads as an unresolved placeholder rather than a language name.

Where a repository's `docs/ai/` already contains documents, the language those
documents are written in wins over (3) — never leave one knowledge base written
in two languages. If (1) conflicts with what is already on disk, ask whether
this is a one-off or a change of setting before writing.

This setting governs **written documents only**. Talk to the user in whatever
language they are using; the two are independent, and a Spanish conversation
producing English documents is a perfectly valid configuration.

So if the user writes in a language other than the resolved one, do not switch
the documents silently: say once which language they use and how to change it,
then carry on.

### The prose layer — translated

Headings, table headers, and all written content in `PROJECT.md`,
`LEARNINGS.md`, `sessions/*`, `decisions/*`, and the block added to the
project's agent instructions file.

### The machine layer — never translated

The framework reads these back. A translated token silently breaks it: a
session recorded as `status: cerrado` is a session `/session-start` will find
`active` forever.

| Stays in English | Examples |
|---|---|
| Frontmatter keys | `id`, `status`, `objective`, `base_commit`, `learnings`, `tags` |
| Status values | `active`, `closed`, `abandoned`, `done`, `partial`, `failed`, `skipped`, `blocked` |
| Identifiers | `S001`, `L-0007`, `ADR-0003` |
| File and folder names | `PROJECT.md`, `LEARNINGS.md`, `INDEX.md`, `decisions/`, `sessions/`, `config.yml` |
| Inline knowledge flags | `→ LEARNING:`, `→ DECISION:`, `→ PROJECT:` |
| Agent instruction block markers | `<!-- memento:begin -->` |
| Quoted material | commands, code, paths, error output, user quotes |

Slugs stay lower-case ASCII kebab-case with no accents or non-Latin characters,
even when the language uses them — `S004-migracion-almacen`, not
`S004-migración-almacén`, and never `S004-数据迁移`. Words may come from the
document language; the encoding must survive any filesystem, shell and URL.

### Heading stability

An existing file's headings are the authority: match what is already there
rather than re-translating from the template, or two sessions will produce
`## Resultados` and `## Resultado` and the sections will diverge. Only a file
created for the first time establishes its headings.

Locate a section by reading the file, never by matching an English string.

## 10. Profiles

A profile adapts the framework to a kind of work. It changes exactly three
things, and nothing else:

1. **the survey** — what `/session-init` reads to seed `PROJECT.md`;
2. **the sections** it contributes to `PROJECT.md`;
3. **what counts as a check** — the evidence vocabulary for §6.

Everything else is identical across profiles: the identifiers, the two kinds of
knowledge, the promotion tests, the honesty rules, the commands.

### Available profiles

| Profile | For | Definition |
|---|---|---|
| `code` | applications, libraries, services, infrastructure | `profiles/code.md` |
| `analysis` | pipelines, models, warehouses, metrics, reports | `profiles/analysis.md` |

Read only the active profiles' files, not all of them.

### Selecting a profile

`profile:` in `docs/ai/config.yml`, a list. Defaults to `[code]` when the key is
absent, which is what every repository initialised before profiles existed will
do — correctly.

Real projects are mixed, so the list composes: `[analysis, code]` surveys for
both, contributes both section sets to `PROJECT.md` in the order listed, and
accepts a check that satisfies **either** profile. A dbt repository is a data
project and a code project at once, and pretending otherwise costs evidence.

Where a profile's section already exists in `PROJECT.md` under a different
heading, keep the existing one — §9's heading-stability rule applies here too.

### What a profile must never do

Weaken §6. A profile supplies examples of evidence; it never grants an exemption
from needing any. If a kind of work genuinely has no failable check, that is a
finding to report to the user, not a reason to record `done`.

