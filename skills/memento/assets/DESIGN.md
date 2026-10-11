# <Project name> — design

<Two or three lines: the problem this project solves and for whom. Not the
technology — the point. This is the approved design; the build follows it.>

<!-- Memento — seeded by /session-discover, updated by later discoveries.
     Current design only: history lives in sessions/, dated discoveries in
     LEARNINGS.md, rejected alternatives in decisions/.
     Keep under ~150 lines. Prefix unverified statements `Assumed:` and empty
     sections `TBD:`. Full rules: the plugin's reference/conventions.md. -->

## Scope

**In scope**

- <what this design covers>

**Out of scope**

- <what it deliberately leaves out>

## Architecture

<The shape of the answer in one paragraph: monolith, services, pipeline,
notebook-to-product — and what that choice rules out.>

## Components

| Component | Responsibility | Notes |
|---|---|---|
| `<name>` | <what it owns> | <stack / key decision> |

<!-- One row per component. Responsibility is what it owns, not what it does
     to what. Drop rows that do not apply yet; do not invent components to
     fill the table. -->

## Data

<Entities and their grain, one line each — "one row per X per Y". Omit this
section if the project holds no data worth modelling.>

## External systems

Names and roles only — never credentials, tokens or connection strings.

| System | Role | How access will be configured |
|---|---|---|
| `<name>` | <what it is used for> | <env var name / config file / secret manager> |

## Constraints

<Hard limits that shape solutions: performance budgets, data volumes,
compatibility requirements, compliance rules, things that must not change.>

## Open questions

Unresolved things a future session could settle.

- <question> — <what would answer it>

<!-- Remove each one as it is answered: a stale question wastes attention every
     session. -->

## Build order

Incremental slices, each small enough to become one `/session-start`
objective, riskiest assumption first.

1. <first slice — the riskiest assumption, tested earliest>
2. <second slice>
3. <third slice>

---
*Approved: <YYYY-MM-DD> (S000)*
