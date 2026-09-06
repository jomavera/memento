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

Objective as given by the user: $ARGUMENTS

Read `${CLAUDE_PLUGIN_ROOT}/reference/conventions.md` once, now. It defines
every path, identifier and rule below. Do not re-read it later in the session.

## Phase 1 — Load

1. If `${CLAUDE_PROJECT_DIR}/docs/ai/` does not exist, run the `/session-init`
   procedure inline first, then continue. Do not stop to ask.
2. Read `docs/ai/config.yml`. It gives two things:
   - the **document language** (§9): this file, else
     `${user_config.document_language}` (ignore it if empty or still literal),
     else English. Everything written to `docs/ai/` uses it, with the machine
     layer from §9 staying English.
   - the **profile** (§10), defaulting to `[code]` if absent. Read
     `${CLAUDE_PLUGIN_ROOT}/reference/profiles/<name>.md` for each active one —
     only those. Its evidence vocabulary is what Phase 3 plans against.
3. Read `docs/ai/PROJECT.md` in full.
4. Read `docs/ai/LEARNINGS.md` under the budget in §3 of the conventions.
5. Read `docs/ai/sessions/INDEX.md`. Open the one or two past logs whose
   objectives touch this one — no more.
6. Read the ADRs in `docs/ai/decisions/` that govern the area about to be
   touched, via the index in `decisions/README.md`.
7. If a session is already `active`, stop and offer three choices: resume it,
   close it with `/session-close`, or mark it `abandoned`. Never open a second
   active session.
8. If the repository is a git repository, capture the branch and HEAD.

Then, in **at most five lines**, tell the user what the accumulated knowledge
says that bears on this objective — relevant learnings, governing decisions,
open questions it might answer. If nothing bears on it, say so in one line.
This is the payoff of the whole framework; do not skip it, and do not pad it.

## Phase 2 — Agree the objective

The objective is a contract, and a vague one produces a worthless log.

Turn the user's request into:

- **one sentence** naming the outcome, not the activity
  — "cut the nightly load below 15 min", not "look at performance";
- **done when** — one to three checkable conditions;
- **not doing** — anything adjacent the user might assume is included.

Draft all three yourself from what the user said and the knowledge you just
loaded. Then check in **once**:

- If a reading is genuinely ambiguous in a way that changes the work, use
  `AskUserQuestion` with the concrete alternatives.
- Otherwise show your draft and ask for confirmation or correction in one line.

Do not interrogate the user. One round, then proceed.

If the objective needs more than about seven stages, say so and propose splitting
it across sessions — that is a finding, not an obstacle.

## Phase 3 — Plan the stages

Propose 3–7 stages. Each one gets:

- a short imperative name;
- one deliverable;
- **one check** that decides whether it worked, drawn from the active profile's
  evidence vocabulary. It must be able to fail: name what would have made it
  come out the other way. A stage whose check is "looks right" has no check —
  find a real one, or merge the stage into its neighbour. If a stage genuinely
  admits no failable check, say so out loud rather than inventing one.

Order them so the riskiest assumption is tested earliest. Say which stage is
the risky one and what happens to the plan if it fails.

Present the plan and get the user's go-ahead before writing.

## Phase 4 — Write the log

1. Assign the next session ID from `INDEX.md` (conventions §2).
2. Create `docs/ai/sessions/YYYY-MM-DD-S<NNN>-<slug>.md` from
   `${CLAUDE_PLUGIN_ROOT}/templates/SESSION.md`, `status: active`, stages as an
   unchecked list, results and validation sections empty. Write it in the
   resolved language; keep the slug ASCII kebab-case and the machine layer
   English, per conventions §9.
3. Record `${CLAUDE_SESSION_ID}` in the frontmatter as `claude_session_id`, so
   the log can be tied back to this transcript via `claude --resume`.
4. Add the row to `INDEX.md`, newest first, status `active`.
5. Report the log path and the first stage. Then start work.

---

## During the session — keep this protocol until `/session-close`

- **Write each stage's record when that stage ends**, into the session log, in
  the session's document language. Never batch to the end: a context window that
  runs out must not take the record with it. Status, result, validation verdict,
  surprises — 3–8 lines, per conventions §6.
- **Run the check.** A stage is `done` only if its check ran and passed.
  Not run → `skipped` with the reason. Failed → `failed` with the output.
  Never write a verdict you did not observe.
- **Plan changes go in the log, not around it.** Adding, dropping or reordering
  a stage is fine; do it explicitly in the log with a one-line why.
- **Flag knowledge inline as you hit it**, in the stage's notes:
  - `→ LEARNING:` something non-obvious that will apply again
  - `→ DECISION:` a choice that rejected a real alternative
  - `→ PROJECT:` a durable fact about the project that changed
  These are candidates; `/session-close` judges them against the promotion
  tests. Flag on the generous side, promote on the strict side.
- **Do not touch `PROJECT.md`, `LEARNINGS.md` or `decisions/` mid-session.**
  Distillation is `/session-close`'s job, once, with the full session in view.
- If the objective turns out to be wrong or unreachable, say so and stop. A
  session that gets abandoned with a clear reason is a good outcome; one that
  quietly drifts to a different objective is not.
