# session-discover — design a project that does not exist yet

The user's idea is the argument in the harness context.

Use this when there is no code to survey yet: a greenfield project in its
analysis and ideation phase, "how should this be designed". If the repository
already has code to work on, stop and redirect — `/session-init` on a first
run, `/session-start` otherwise. Discovery produces an approved design, never
an implementation.

Read `references/conventions.md` once, now. It defines every path, identifier
and rule below. Do not re-read it later in the discovery.

## Step 0 — Bootstrap, only if `docs/ai/` is missing

If `docs/ai/` already exists, skip this step entirely — never overwrite
anything.

Otherwise create the skeleton without surveying any code, because there is
none to survey:

1. Resolve the document language per conventions §9: the argument from the
   harness context if the user named one, else the default from the harness
   context, else English.
2. Propose the profile from the user's idea in one line — `[code]` for
   software, `[analysis]` for data work, both where both apply — and accept a
   correction; do not stop to ask. Default to `[code]` when nothing is
   conclusive.
3. Copy the structure from `assets/`: `config.yml`, `PROJECT.md`,
   `LEARNINGS.md`, `sessions-INDEX.md` (as `sessions/INDEX.md`),
   `decisions-README.md` (as `decisions/README.md`). Set `language:` and
   `profile:` in `config.yml`. Leave `PROJECT.md` as a skeleton: every section
   stays `TBD: not yet established.` It gets seeded from the approved design
   in Step 5, not from a survey.
4. Register the convention block from `assets/AGENTS-section.md` in `AGENTS.md`
   (or `CLAUDE.md` if that is what the repository has), creating the file if
   neither exists.

Then continue. Do not report yet — the report comes at the end.

## Step 1 — Align on what is being designed

Turn the user's idea into, in your own draft:

- **problem** — two or three lines: what hurts and for whom;
- **users** — who consumes this, and what decision or task it serves;
- **in scope / out of scope** — what this design covers and what it
  deliberately leaves out;
- **constraints** — hard limits that shape the answer: budget, volume,
  latency, compliance, things that must not change;
- **open questions** — what nobody knows yet, and what would answer each.

Draft all five yourself, then check in **once**:

- If a reading is genuinely ambiguous in a way that changes the design, ask
  the user to choose between the concrete alternatives — not an open question.
- Otherwise show your draft and ask for confirmation or correction in one line.

Do not interrogate the user. One round, then proceed.

If aligning reveals the repository already has code and the real objective is
to implement something, stop: say so in one line and redirect to
`/session-start`. Discovery that drifts into implementation is the failure
this check prevents.

## Step 2 — Investigate the options

Evaluate, at most three candidates per decision:

- the stack or platform candidates, with one line each for why it fits or not;
- the architecture shape — monolith, services, pipeline, notebook-to-product,
  whatever the idea calls for — and what it rules out;
- the external systems involved: names and roles only, never credentials;
- where data is central, the entities and their grain, in one line each.

Do not write source code. Do not scaffold the project. Research from what you
know; do not invent benchmarks, prices or limits — an unverified claim is
marked `Assumed:`, a missing one `TBD:`.

Flag knowledge candidates as you hit them, in your own notes:

- `→ DECISION:` a choice that rejected a real alternative;
- `→ PROJECT:` a durable fact about the future project.

Learnings rarely apply yet — there is no recurring practice to distil. Flag
one only if it genuinely will.

## Step 3 — Propose the design

Write `docs/ai/DESIGN.md` from `assets/DESIGN.md`, in the resolved language,
keeping the machine layer English per conventions §9. Keep it under ~150
lines: problem, scope, architecture, components, external systems,
constraints, open questions, and a **build order** of 3–7 incremental slices,
each slice small enough to become one future `/session-start` objective.

Show the user a summary in at most ten lines: the architecture in one
sentence, the stack, the slices, and what is still `TBD`.

## Step 4 — Validate with the user

Get an explicit verdict: **approved** or **not approved, with the reason**.
One revision round is included — adjust `DESIGN.md` and present the diff in
words, briefly. After a second round without approval, stop pushing: close as
abandoned with the reason recorded. An unexplored disagreement documented
honestly beats a design approved by exhaustion.

The approval is the check this discovery ran. Write down who approved what and
when; "user approved the design on <date>" is evidence, "design validated" is
a claim.

## Step 5 — Close

1. Assign the next session ID from `docs/ai/sessions/INDEX.md` (conventions
   §2). Create `docs/ai/sessions/YYYY-MM-DD-S<NNN>-<slug>.md` from
   `assets/SESSION.md` with `status: closed`, `closed` set to today, tags
   `[discovery]`, and the objective as the outcome: "Approved design for
   <X>" — or "Explored <X>, not approved", with the reason, when abandoned.
   Record the four steps above as the stage records, 3–8 lines each; the
   validation of Step 4 is the user's verdict, quoted. Leave
   `claude_session_ids` empty: the log closes immediately, so there is
   nothing a later conversation needs to recover.
2. Seed `docs/ai/PROJECT.md` from the approved `DESIGN.md`: what the project
   will be, the decided stack, components and constraints. Everything
   undecided stays `TBD:`. Respect the ~200-line cap — on a first seeding you
   should be far under it.
3. For each `→ DECISION:` flag, apply the ADR promotion test (conventions
   §5): a genuine rejected alternative plus real reversal cost. Survivors get
   `docs/ai/decisions/ADR-<NNNN>-<slug>.md` from `assets/ADR.md` plus an index
   line. Expect zero or one. Zero is the normal result when the design settled
   nothing costly yet.
4. Add the row to `docs/ai/sessions/INDEX.md`, newest first, with the final
   status, the one-line outcome and any ADR ids.
5. Report, compactly: the `DESIGN.md` path; what `PROJECT.md` now says; new
   ADRs or explicitly none and why; the suggested first `/session-start`
   objective (build-order slice 1); and the commit command, e.g.
   `git add docs/ai AGENTS.md && git commit -m "Approve design for <X>"`.
   Offer it; do not run it unless the user asks.

Then confirm the discovery is closed. The next command on this path is
`/session-start`, never `/session-init` — the bootstrap already happened in
Step 0.

---

## Rules that hold for the whole discovery

- **One active session at a time** (conventions §7). If a session is already
  `active`, stop before Step 0 and tell the user to resume or close it first.
  Discovery never runs alongside work.
- **No source code.** Discovery writes under `docs/ai/` and the agent
  instructions file only. A prototype the user asks for mid-discovery is a
  future session's scope, not this one's.
- **`LEARNINGS.md` stays untouched** unless a candidate passes all three
  promotion tests, which at this stage is rare. Say "none" and why.
- If the idea turns out to be unworkable, say so and close as abandoned with
  the reason. A documented dead end before any code exists is the cheapest
  good outcome this framework produces.
