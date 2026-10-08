# session-init — bootstrap Memento in a repository

Read `references/conventions.md` before doing anything. It defines every path,
identifier and rule used below.

## 0. Resolve the document language

Per conventions §9, in this order:

1. The argument from the harness context, if the user named a language.
2. The default document language from the harness context, if one was given.
3. English.

This decides the language of every document created below. The machine layer in
§9 stays English regardless — that table is not a style preference, it is what
keeps the framework able to read its own output.

## 1. Check what already exists

The target is `docs/ai/`.

If it already exists: do **not** overwrite anything. List which of the expected
files are present and which are missing, create only the missing ones, and stop.
`/session-init` is idempotent and never destructive.

## 2. Decide the profile

Per conventions §10, the profile decides what to survey, which sections
`PROJECT.md` carries, and what counts as a check.

Glob the repository for the signals, then propose:

| Seen | Suggests |
|---|---|
| `dbt_project.yml`, `models/**/*.sql`, notebooks, DAGs, a data dictionary, BI model files | `analysis` |
| package or build manifests, source trees, CI workflows, tests | `code` |
| both | `[analysis, code]`, in that order |

State what you found and which profile follows from it, in one line. Accept a
correction; do not stop to ask. Default to `[code]` when nothing is conclusive.

Then read `references/profile-<name>.md` for each active
profile — only those.

## 3. Survey the repository before writing a word

`PROJECT.md` must be seeded from evidence in the repository, not from assumption.
Follow the **Survey** section of each active profile, in order.

Then, if the repository is a git repository, get the current branch and the most
recent commit subjects (`git log --oneline -20`) to see what the project has
actually been working on lately.

## 4. Create the knowledge base

Copy the structure from `assets/`:

| Template | Destination |
|---|---|
| `config.yml` | `docs/ai/config.yml` |
| `PROJECT.md` | `docs/ai/PROJECT.md` |
| `LEARNINGS.md` | `docs/ai/LEARNINGS.md` |
| `sessions-INDEX.md` | `docs/ai/sessions/INDEX.md` |
| `decisions-README.md` | `docs/ai/decisions/README.md` |

Set `language:` and `profile:` in `docs/ai/config.yml` to what steps 0 and 2
resolved, so later sessions in this repository do not have to be told again.
Keep that file's comments in English — it is framework configuration, not
project documentation.

`assets/PROJECT.md` is the profile-neutral spine. Insert each active
profile's **Sections contributed to PROJECT.md** block at the marker, in the
order the profiles are listed, and delete the marker comment.

Write the other four in the resolved language, translating headings and prose
while leaving the machine layer alone.

`SESSION.md` and `ADR.md` are not copied now — `/session-start` and
`/session-close` use them per session.

## 5. Fill PROJECT.md from what you found

Replace each placeholder with what the survey actually established.

- A fact you verified → state it plainly.
- A fact you inferred but did not verify → prefix `Assumed:`.
- A section with no evidence → leave the single line `TBD: not yet established.`

Commands must be the **exact** invocations, copied from the manifest, CI config
or scheduler that defines them — not a plausible guess. A wrong command in
`PROJECT.md` costs every future session a failed run.

Do not exceed the ~200-line cap. On a first pass you should be well under it;
an over-long seed is a sign you are transcribing the project instead of mapping it.

## 6. Register the convention in the project's agent instructions

Append the block from `assets/AGENTS-section.md` to the repository's agent
instructions file: `AGENTS.md`, unless the repository already has a `CLAUDE.md`,
in which case append there instead. Create `AGENTS.md` if neither exists.

The block is delimited by `<!-- memento:begin -->` and
`<!-- memento:end -->`. If those markers are already present,
replace what is between them instead of appending a second copy. Translate the
block's prose into the resolved language; leave the markers and the paths exactly
as they are.

This block is what lets a session that never runs `/session-start` still know
the knowledge base exists.

## 7. Report

State:

- the files created, by path;
- the profile and the document language, and that `docs/ai/config.yml` is where
  to change either;
- which `PROJECT.md` sections are still `TBD`, and what would resolve each;
- the command to commit, naming the agent instructions file actually written:
  `git add docs/ai AGENTS.md && git commit -m "Add AI session knowledge base"`.

Do not run the commit. Then say that `/session-start` is the next step.
