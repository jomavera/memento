# <Project name> — project map

<Two or three lines: what this project does and who consumes it. Not the
technology — the point.>

<!-- Profile sections go here, in the order the profiles are listed in
     config.yml. See reference/profiles/<name>.md. -->

## Commands

| Purpose | Command |
|---|---|
| Install | `<...>` |
| Run | `<...>` |
| Test | `<...>` |
| Build | `<...>` |
| Deploy | `<...>` |

<!-- Exact invocations, copied from the manifest, CI config or scheduler that
     defines them. A wrong command here costs every future session a failed run.
     Drop rows that do not apply; add the ones that do. -->

## External systems

Names and roles only — never credentials, tokens or connection strings.

| System | Role | How access is configured |
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

## Where else to look

- `<path>` — <what it documents>

---
*Last curated: <YYYY-MM-DD> (S000)*

<!-- Memento — maintained by /session-close.
     Current facts only: history lives in sessions/, dated discoveries in
     LEARNINGS.md, rejected alternatives in decisions/.
     Hard cap ~200 lines for the whole file, comments included: prune before you
     add. Prefix unverified statements `Assumed:`; empty sections `TBD:`.
     Full rules: the plugin's reference/conventions.md, sections 3, 5 and 10. -->
