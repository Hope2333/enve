# AI Workbench

This is the human-facing control panel for AI collaboration in this repository.

## Use This First

If you only want one document to look at before talking to an AI, use this one.

## Current System

- Global relay rules: `docs/ai-relay.md`
- AI role split and detailed contracts: `docs/ai-collaboration.md`
- Active modernization lane: `docs/modernization/ai-handoff.md`
- Active status summary: `docs/modernization/current-status.md`
- Active medium-term plan: `docs/modernization/phase-2-roadmap.md`

## Default Language Split

- AI-to-AI relay content, prompts, commands, file paths, and technical evidence: English
- Human-facing summaries, evaluations, plans, and final conclusions: Chinese by default
- Technical identifiers such as paths, commit IDs, workflow IDs, and code symbols stay in original English form
- If you want a different language for one run, override it in a human addendum instead of rewriting the whole prompt

## Which Prompt To Use

### 1. Lower-Cost Execution

Use when you want the cheaper AI to keep coding inside the current lane.

```text
Read AGENTS.md, docs/ai-relay.md, docs/ai-collaboration.md, and the active lane docs listed in docs/ai-relay.md.

You are the lower-cost execution AI.

Language contract:
- use English for relay-file updates, task instructions, code references, commands, and technical evidence
- use Chinese for the final summary to the human
- keep file paths, commit IDs, workflow IDs, and code identifiers in their original English form

Before coding, derive a layered TODO list with:
- lane goal
- current batch
- immediate next tasks

Stay inside the active lane, make the smallest correct change, work through that layered TODO list autonomously, run local verification, inspect or trigger CI as needed, and update the active handoff docs after every meaningful state change.

For simple sidecar tasks, you may use up to 3 parallel subagents such as:
- `explorer` for codebase discovery
- `researcher` as a librarian or oracle equivalent for references
- `verifier` for read-mostly checks

For GitHub Actions waits, use `scripts/ci/watch-build-status.sh`.
For long-running local logs, use `scripts/ci/wait-log-pattern.sh`.

Hand back after 5 to 10 meaningful steps, or immediately on a new blocker, first green build, PR readiness point, or phase-boundary question.

When handing back, include the current layered TODO state:
- lane goal
- current batch
- immediate next tasks

Do not start a new phase on your own, do not broaden scope casually, do not use more than 3 subagents in parallel, do not delegate the critical-path implementation step, and do not leave the handoff docs stale.
```

### 2. Supervisory Checkpoint

Use when you want the more expensive AI to do evaluation plus planning, not just a status check.

```text
Read AGENTS.md, docs/ai-relay.md, docs/ai-collaboration.md, and the active lane docs listed in docs/ai-relay.md.

You are the higher-cost supervisory AI.

Language contract:
- use English for relay-file updates, task instructions, and technical evidence
- use Chinese for the human-facing evaluation and planning output
- keep file paths, commit IDs, workflow IDs, and code identifiers in their original English form

Produce both:
- a current-state evaluation
- a forward plan

Decide whether the execution AI should continue, narrow scope, pivot, merge, or change phase.

Your output should include:
- current-state evaluation
- immediate next 1 to 3 actions
- medium-term plan adjustment
- ultra-long-term implication or phase-boundary note
```

### 3. Long-Term / Ultra-Long-Term Planning

Use when you want route changes, phase reordering, or long-horizon product and architecture judgment.

```text
Read AGENTS.md, docs/ai-relay.md, docs/ai-collaboration.md, and the active lane docs listed in docs/ai-relay.md, plus any roadmap or dependency docs referenced there.

You are the long-range planning AI.

Language contract:
- use English for relay-file updates, roadmap references, and technical evidence
- use Chinese for the human-facing planning output
- keep file paths, commit IDs, workflow IDs, and code identifiers in their original English form

Evaluate the current state of the active lane, refine the next-phase plan, identify what must stay out of scope, and surface ultra-long-term implications for architecture, dependency strategy, and future major migrations.

Your output should include:
- current-state evaluation
- next-phase plan
- ultra-long-term plan implications
- risk ranking
- deferred work that must stay out of scope for now
- exact document(s) that should be updated to preserve relay quality
```

## Recommended Operating Cadence

1. Let the lower-cost AI do 5 to 10 meaningful steps.
2. Require it to update handoff docs.
3. Bring the supervisory AI back for evaluation plus planning.
4. Only let the supervisory AI code directly when the lane is blocked or drifting.

## Wait Tools

- `scripts/ci/watch-build-status.sh`: wait for a GitHub Actions run to reach a terminal state.
- `scripts/ci/wait-log-pattern.sh`: wait on a local log file with fixed-string success and error markers.

## When To Open A New Lane

Open a new lane when work is no longer a narrow follow-up inside the current modernization lane. Good examples:

- multilingual or i18n system
- packaging redesign
- plugin architecture
- exporter/importer overhaul
- CMake migration
- Qt 6 migration

## New Lane Bootstrap

When a new lane is needed:

1. Create `docs/features/<lane>/ai-handoff.md` from `docs/templates/feature-lane-handoff.template.md`.
2. Create `docs/features/<lane>/roadmap.md` from `docs/templates/feature-roadmap.template.md`.
3. Register the new lane in `docs/ai-relay.md`.
4. Mark whether it is active, parked, or blocked.
5. Make all future prompts point to `docs/ai-relay.md` rather than hardcoding the new file list manually.

## Human Rule Of Thumb

If you find yourself pasting more than one block of prompt plus more than one block of repo status by hand, stop and update the lane docs instead. The prompts should stay stable; the docs should carry the moving state.

## Human Addendum Template

Paste a stable prompt first, then append a short addendum such as:

```text
===== HUMAN ADDENDUM =====
- Use Chinese for the final summary to me.
- Keep relay updates in the lane docs.
- Do not broaden scope beyond the active lane unless the docs clearly require it.
```

The addendum is where you change language, scope, urgency, or lane-specific emphasis for one run.
