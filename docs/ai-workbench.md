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

## Which Prompt To Use

### 1. Lower-Cost Execution

Use when you want the cheaper AI to keep coding inside the current lane.

```text
Read AGENTS.md, docs/ai-relay.md, docs/ai-collaboration.md, and the active lane docs listed in docs/ai-relay.md.

You are the lower-cost execution AI.

Stay inside the active lane, make the smallest correct change, run local verification, inspect or trigger CI as needed, and update the active handoff docs after every meaningful state change.

Hand back after 5 to 10 meaningful steps, or immediately on a new blocker, first green build, PR readiness point, or phase-boundary question.

Do not start a new phase on your own, do not broaden scope casually, and do not leave the handoff docs stale.
```

### 2. Supervisory Checkpoint

Use when you want the more expensive AI to do evaluation plus planning, not just a status check.

```text
Read AGENTS.md, docs/ai-relay.md, docs/ai-collaboration.md, and the active lane docs listed in docs/ai-relay.md.

You are the higher-cost supervisory AI.

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
