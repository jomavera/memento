---
id: S000
slug: <kebab-case-slug>
date: <YYYY-MM-DD>
closed: <YYYY-MM-DD or empty while active>
status: active            # active | closed | abandoned
objective: <one sentence, the outcome>
claude_session_id: <${CLAUDE_SESSION_ID}>
branch: <git branch, omit if not a git repository>
base_commit: <short sha at open, omit if not a git repository>
end_commit: <short sha at close, omit if not a git repository>
learnings: []             # [L-0007, L-0008]
decisions: []             # [ADR-0003]
tags: []                  # 2-4 area tags, e.g. [etl, dbt]
---

# S000 — <objective as a short title>

## Objective

<One sentence naming the outcome, not the activity.>

**Done when**
- [ ] <checkable condition>
- [ ] <checkable condition>

**Not doing**
- <adjacent thing deliberately out of scope>

## Context loaded at start

<Up to five lines: which learnings, ADRs and past sessions bear on this
objective, and what they say. "Nothing in the knowledge base bears on this"
is a valid and useful answer.>

## Stages

### 1. <imperative name> — `status`

- **Result:** <the deliverable, and what changed, by path>
- **Validation:** `<the exact check>` → <verdict>
- **Notes:** <only surprises, blockers, or what a future session must know>

### 2. <imperative name> — `status`

- **Result:**
- **Validation:**
- **Notes:**

<!-- Memento —
status: done | partial | failed | skipped | blocked

Write each record when the stage ends, not at close time.

Flag knowledge candidates inline in Notes:
  → LEARNING: <non-obvious thing that will apply again>
  → DECISION: <choice that rejected a real alternative>
  → PROJECT: <durable project fact that changed>

Plan changed? Add, drop or reorder stages here explicitly, each with a one-line
why. Never silently edit the plan to match the outcome.
-->

## Results

<What now exists that did not before, and what changed, by path. Two to six
lines. Not a diff — the diff is in git.>

## Validation

<The checks that ran and their verdicts, failures included. Then: done-when
conditions met / partially met / not met, and which one failed.>

## Handoff

- **Open threads:** <what is unfinished, and where it stands>
- **Known broken:** <anything left in a bad state, or "nothing">
- **Deliberately not done:** <so the next session does not redo the decision>
- **Best next step:** <one specific, actionable thing>
