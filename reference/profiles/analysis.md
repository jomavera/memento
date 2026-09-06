# Profile: analysis

Data work — pipelines, models, warehouses, metrics, reports and the numbers
that come out of them.

## Survey

What `/session-init` reads to seed `PROJECT.md`, in this order:

1. `README*`, `CLAUDE.md`, and any existing data dictionary or glossary
2. Transformation projects — `dbt_project.yml` with `models/` and its
   `schema.yml` / `sources.yml`, SQL files, notebooks, ETL scripts
3. Orchestration — Airflow DAGs, scheduler configs, job definitions: what runs,
   how often, and what depends on what
4. Semantic and BI layers — metric definitions, Power BI / Looker / Tableau
   model files, saved queries
5. Source system configs — record the system, the schema and how access is
   configured, **never a credential**
6. Existing tests and quality checks — `dbt test`, Great Expectations suites,
   assertion scripts. What is already guarded tells you what is not.

Note explicitly which numbers the project publishes and who consumes them. A
data project's blast radius is the decisions people make on its output.

## Sections contributed to PROJECT.md

```markdown
## Data sources and grain

| Source | System | Grain | Refresh | Notes |
|---|---|---|---|---|
| `<table / dataset>` | `<system>` | <one row = ...> | <cadence> | <caveat> |

<The grain column is the one that prevents silent double-counting. State it as
"one row per X per Y", never as a table name.>

## Metric definitions

<For each published metric: exactly how it is computed, which filters and
exclusions apply, and the period convention. Where two definitions of the same
word exist in the business, say both and say which one this project uses.>

- **<metric>** — <definition> · excludes <...> · period: <...>

## Pipelines and schedule

<What runs, in what order, on what trigger, and what breaks downstream when a
step fails. Only the dependencies that are not obvious from the file layout.>

## Known data caveats

<Things that are true about the data and will bite someone who does not know:
duplicated keys in a source, a backfill gap, a system that reports in a
different timezone, a field that changed meaning on a date.>
```

## What counts as a check

Reconciliation against something **independent of the work that produced the
number**. Running without error is not a check: bad SQL usually returns a
confident wrong answer rather than an exception.

- totals tie to the system of record — record **both figures**, not "matched"
- row counts before and after match what the transformation should do, and any
  discrepancy is explained rather than rounded away
- N specific records traced end to end against the source, with the identifiers
  written down so someone can repeat it
- the metric recomputed by a second, independent method agrees
- schema, freshness and uniqueness tests pass — `dbt test`, Great Expectations,
  assertion queries
- a known-answer case reproduces: a period whose correct figure is already known
  from an audited report comes out right
- for a fix: the specific wrong rows are now right, **and** the count of rows the
  change touched is what you predicted

**Not a check:** the query ran; the chart looks plausible; the number is in the
right ballpark; the row count "seems reasonable"; a comparison against another
figure this same project produced.

Write the numbers into the session log, not a verdict. `4.182.331.220 in the
report vs 4.182.331.220 in the ERP (query in assets/recon.sql)` is evidence;
"reconciled correctly" is a claim. When a reconciliation fails, the gap is the
finding — record its size and direction before explaining it away.
