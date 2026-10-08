# Memento — a lean session framework

A micro-framework for working with Claude Code in any project, with two
commands. Each session gets a traceable log; each closed session feeds a
cumulative knowledge base that makes the next session start smarter.

It is not only for code. A profile adapts it to software or to data work, and
the part that changes is what counts as proof that a stage actually worked.

## Why

Claude Code sessions are stateless. Everything worked out in one session — the
gotcha that cost an hour, the alternative that turned out to be a dead end, the
exact command that actually works — is gone when the session ends, and the next
session pays for it again. Hence the name: an agent that cannot form new
memories has to leave itself notes, and the notes have to be worth reading.

Two things fix that, and they are different things:

- **Traceability** — a record of *what was attempted and what came of it*, so a
  human can see progress across sessions.
- **Cumulative knowledge** — a curated set of *facts that are still true*, so an
  agent starts informed instead of guessing.

This framework keeps them separate on purpose, and bridges them at exactly one
point: session close.

## Install

Register this repository as a marketplace, once:

```
/plugin marketplace add jomavera/memento
```

Then install the plugin:

```
/plugin install memento@memento
```

The commands become available in every repository. To try it without
installing, clone the repo and run `claude --plugin-dir ./memento`.

## The three commands

| Command | When | What it does |
|---|---|---|
| `/session-init` | Once per repository | Creates `docs/ai/`, sets the document language, seeds `PROJECT.md` from what the repo already documents, registers the convention in `CLAUDE.md`. |
| `/session-start` | Before substantial work | Loads the knowledge base, tells you what bears on your objective, agrees the objective and done-when conditions, plans 3–7 stages, opens the log. |
| `/session-close` | Before ending work | Re-runs the checks, finishes the log honestly, distills learnings and decisions, curates `PROJECT.md`, updates the index. |

Between start and close there are no commands. Stage records are written into
the log as each stage ends, and knowledge candidates are flagged inline. That is
the whole ceremony.

Two more exist outside the work cycle. Neither is ever required:

| Command | When | What it does |
|---|---|---|
| `/project-brief` | Picking a repository back up, or handing it to someone | Reads the knowledge base and answers "where does this stand?" in the terminal. Writes nothing — `Write` and `Edit` are withheld while it runs, so that is a guarantee, not a promise. |
| `/memento:doctor` | Occasionally, or when something looks off | Audits the knowledge base: dangling sessions, broken links, duplicate ids, a translated machine layer, files gone stale or over budget. `--fix` applies only the mechanical repairs. |

`/memento:doctor` needs its namespace: `/doctor` is one of Claude Code's own
bundled commands and cannot be displaced.

## A session is not a conversation

A session here is a unit of *work with one objective*. A Claude Code
conversation is a unit of *context*. They are independent, and the only rule
tying anything down is per repository: **one `active` session at a time**.

So both of these work:

- **Several sessions in one conversation.** `/session-start`, work,
  `/session-close`, then start another. The second finds no active session and
  opens a fresh log with the next id.
- **One session across several conversations.** This is what the during-session
  protocol is built for. Stage records are written as each stage ends, never
  batched, so a context window that runs out does not take the record with it.
  Open a new conversation and run `/session-start` again: it finds the `active`
  session and offers to resume it, close it, or abandon it.

Match a session to an objective, not to a sitting. Where it is convenient,
prefer a fresh conversation per session — the knowledge is meant to travel in
`docs/ai/`, not in the context window, and a conversation still holding three
closed sessions makes the briefing at `/session-start` theatre. The opposite
case, one session spanning three conversations because the work is genuinely
long, is the framework working as intended.

## What it produces, in the target repository

```
docs/ai/
├── config.yml                          Settings for this repo, e.g. document language.
├── PROJECT.md                          Current map of the project. ~200 lines, hard cap.
├── LEARNINGS.md                        Append-only ledger of durable discoveries.
├── decisions/
│   ├── README.md                       ADR index.
│   └── ADR-0001-<slug>.md              One significant choice, with what it rejected.
└── sessions/
    ├── INDEX.md                        Traceability table, newest first.
    └── 2026-09-04-S001-<slug>.md       One session: objective, stages, results, handoff.
```

All of it is committed alongside the code, so the knowledge travels with the
repository and is reviewable in pull requests.

## Profiles

The framework is not tied to software. A **profile** adapts it to the kind of
work, and changes exactly three things — what gets surveyed, which sections
`PROJECT.md` carries, and **what counts as a check**. Everything else is
identical.

| Profile | For | A check means |
|---|---|---|
| `code` | applications, libraries, services, infrastructure | a command whose exit status decides it — tests, linter, build, a smoke request |
| `analysis` | pipelines, models, warehouses, metrics, reports | reconciliation against something independent — totals tying to the system of record, row counts, records traced to source, `dbt test`, a known-answer period reproducing |

Set it in `docs/ai/config.yml`; `/session-init` proposes one from what it finds
in the project. It is a list, because real projects are mixed — a dbt repository
is both, and `[analysis, code]` surveys for both and accepts a check that
satisfies either.

The third thing is the one that matters. Porting a session framework out of
software fails at verification: there is no test suite for a report, and
"Validation" quietly degrades into "I reviewed it". So the rule was hardened
rather than relaxed — **a check must be able to fail**, and you must be able to
name what would have made it come out the other way. `analysis` earns this
easily: "the query ran" is not a check, because bad SQL returns a confident
wrong answer instead of an error; "4.182.331.220 in the report vs 4.182.331.220
in the ERP" is, because the two numbers might not have matched.

Adding a profile means writing one file under `skills/memento/references/` with
those three sections. Nothing in the core changes.

## Language

Generated documents are in **English by default**, and can be in any language.
Three levels, most specific first:

| Level | Where | Scope |
|---|---|---|
| This request | Name it when you run `/session-init "Spanish"`, or just say so | One-off |
| This repository | `language:` in `docs/ai/config.yml` | Every session in the repo |
| This machine | `document_language` in the plugin's settings (`/plugin`) | Default for new repos |

What the setting does **not** touch:

- **The conversation.** Talk to Claude in any language; that is independent.
  A Spanish conversation producing English documents is a valid setup.
- **The machine layer.** Frontmatter keys, status values (`active`, `closed`,
  `done`, `skipped`, …), identifiers (`S001`, `L-0007`), file names and slugs
  stay English, because the framework reads them back. A session recorded as
  `status: cerrado` is one `/session-start` would find `active` forever.
- **A knowledge base already on disk.** Its existing language wins over the
  machine default, so a repository never ends up half-translated. Changing
  `config.yml` later affects new writing, not what is already recorded.

Slugs stay lower-case ASCII kebab-case with no accents — `S004-migracion-almacen`
— so paths survive any filesystem, shell and URL.

## Design choices worth knowing

**`PROJECT.md` has a hard line cap.** It is read at the start of every session,
so its size is a cost paid forever. `/session-close` prunes before it adds. The
most expensive failure mode of a knowledge base is not being empty — it is
growing until nobody can afford to load it.

**Promotion is strict, flagging is generous.** During a session, anything
interesting gets flagged. At close, each candidate must pass explicit tests
before it becomes a learning or an ADR. Zero learnings from a session is a
normal, honest result.

**Validation cannot be asserted, only observed.** A stage is `done` only if its
check ran and passed. `/session-close` re-runs cheap checks rather than trusting
a verdict from twenty turns earlier, and reports failures as failures.

**Closed logs are immutable.** A later correction goes in a new session with a
supersession note. A log that gets rewritten to match how things turned out is
worth nothing.

**Abandoned is a real outcome.** A session that ends without meeting its
objective still closes properly, recording why. An undocumented dead end gets
walked into twice.

**Content first, machinery in HTML comments.** Every generated file opens with
what a person came to read; the rules about how the file is maintained sit in
`<!-- comments -->`, invisible in GitHub and any editor preview, still readable
to an agent that opens the file. These documents have two audiences, and the
human one should not have to scroll past instructions addressed to the other.

## Layout of this plugin

```
memento/
├── .claude-plugin/plugin.json
├── skills/
│   ├── memento/                    The canonical bundle — everything lives here.
│   │   ├── SKILL.md
│   │   ├── references/
│   │   │   ├── conventions.md      Paths, ids, budgets, promotion tests, language.
│   │   │   ├── profile-code.md     Survey, PROJECT.md sections, evidence vocabulary.
│   │   │   ├── profile-analysis.md
│   │   │   ├── session-init.md     The five procedures.
│   │   │   ├── session-start.md
│   │   │   ├── session-close.md
│   │   │   ├── project-brief.md
│   │   │   └── doctor.md
│   │   └── assets/
│   │       ├── PROJECT.md   LEARNINGS.md   SESSION.md   ADR.md
│   │       ├── sessions-INDEX.md   decisions-README.md
│   │       ├── config.yml
│   │       └── AGENTS-section.md
│   ├── session-init/SKILL.md       Thin wrappers: one slash command each.
│   ├── session-start/SKILL.md
│   ├── session-close/SKILL.md
│   ├── project-brief/SKILL.md
│   └── doctor/SKILL.md
└── opencode/                       The opencode build. See opencode/README.md.
```

`skills/memento/` is a canonical [Agent Skills](https://agentskills.io) bundle:
every path inside it is relative to the bundle root and there are no variables
to substitute, so it drops into any skills-compatible agent unchanged.

The five wrappers exist because the bundle is deliberately harness-agnostic.
Each one supplies a short **harness context** block — the user's argument, the
default document language, a conversation id — and then points at its procedure.
That is the only place anything harness-specific lives, which is what lets the
same bundle serve Claude Code and opencode without a fork.

To change how the framework behaves, edit
`skills/memento/references/conventions.md` — every procedure defers to it rather
than restating the rules.

## Other harnesses

Beyond Claude Code, `opencode/install.sh` generates an opencode build: the
bundle copied verbatim, plus five commands and a read-only agent. See
[opencode/README.md](opencode/README.md).

For any other skills-compatible agent — Cursor, Codex, Copilot, Gemini CLI and
the rest — copy `skills/memento/` into that tool's skills directory, or into the
cross-tool `.agents/skills/` convention. It works as-is; without a harness
context block it simply treats every such value as unset.

## Prior art

The split between stable configuration (`CLAUDE.md`), evolving discoveries
(`LEARNINGS.md`) and point-in-time decisions (ADRs) follows the learnings-loop
and memory-bank patterns and Nygard's decision records. The staged plan with an
explicit check per stage borrows from spec-driven approaches such as GitHub Spec
Kit and BMAD-METHOD, deliberately without their gated multi-phase ceremony.
