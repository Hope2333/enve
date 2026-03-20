# AI Collaboration Protocol

This file defines how a higher-cost supervisory AI and a lower-cost execution AI should collaborate in this repository. Human-facing quick entrypoint: `docs/ai-workbench.md`.

## Purpose

Use the lower-cost AI for iterative coding, log collection, CI retries, and bounded fixes. Use the higher-cost AI for long-horizon assessment, gate decisions, sequencing, and risk review.

## Role Split

### Supervisory AI

- Own the long-term evaluation and modernization plan.
- Decide the next milestone, success criteria, and stop conditions.
- Review state at meaningful checkpoints instead of after every tiny change.
- Each review should output both a current-state assessment and a forward plan.
- Update roadmap-level documents when phase status or priorities change.
- Step into direct coding only when the execution lane is blocked, drifting, or making poor tradeoffs.

### Lower-Cost Execution AI

- Execute the current lane with the smallest correct change.
- Use a few subagents when they clearly reduce idle time on simple side tasks.
- Read the active roadmap before coding and derive a layered TODO list:
  - lane goal
  - current batch
  - immediate next tasks
- Run local verification, trigger CI, inspect logs, and make narrow follow-up fixes.
- Stay patient during long-running builds or CI; prefer repo-safe wait loops over bouncing back to the human early.
- Keep commits small and single-purpose.
- Update the active handoff docs after each meaningful state change.
- Return to the supervisory AI at defined review gates instead of endlessly pushing local optimizations.

## Lower-Cost Subagent Guardrails

The lower-cost AI may use subagents, but only under tight limits:

- at most 3 parallel subagents at one time
- reserve them for simple, bounded, mostly read-only tasks
- good fits:
  - `explorer` for codebase search, file mapping, and symbol lookup
  - `researcher` as the closest match to a librarian or oracle role for documentation, references, and external facts
  - `verifier` or a similar read-mostly checker for confirmation work
- do not delegate the immediate blocking implementation step if the main AI needs that result next
- do not fan out speculative work just because more work is visible
- prefer subagents for sidecar tasks that can run while the main AI keeps the critical path moving
- if subagents are used, fold their findings back into the layered TODO state instead of leaving them as detached notes

## Shared Source Of Truth

Every collaborating AI should treat these as the current project memory:

1. `AGENTS.md`
2. `docs/ai-relay.md`
3. `docs/ai-collaboration.md`
4. `docs/modernization/ai-handoff.md`
5. `docs/modernization/current-status.md`
6. `docs/modernization/phased-backlog.md`
7. `docs/modernization/phase-2-roadmap.md`
8. `docs/modernization/phase-1-roadmap.md` as historical context when needed

## Review Cadence

Default loop:

1. Lower-cost AI executes 5 to 10 meaningful steps, or until a gate event happens first.
2. Lower-cost AI updates handoff docs.
3. Supervisory AI reviews and either:
   - approves continuation within the same lane
   - narrows or changes the next target
   - takes over directly for a hard blocker or plan correction

## Long-Run Lower-Cost Pattern

When the lower-cost AI is expected to run with low supervision:

1. Read the active handoff and roadmap first.
2. Extract a layered TODO list before coding:
   - lane goal
   - current batch
   - immediate next tasks
3. Work through that list until a review gate, a real blocker, or a terminal build result appears.
4. If simple sidecar questions appear, use up to 3 lightweight subagents for exploration, research, or verification while the main AI keeps moving.
5. For GitHub Actions waits, use `scripts/ci/watch-build-status.sh`.
6. For local long-running logs, use `scripts/ci/wait-log-pattern.sh` with explicit success and error markers.
7. Hand back only when there is a meaningful state change, not just because a build is still running.

## Mandatory Review Gates

Return to the supervisory AI immediately when any of these happens:

- a new first blocker is identified
- a branch build turns green for the first time
- a master build turns green for the first time
- a PR is opened and merge readiness needs evaluation
- a phase exit criterion is reached or disproved
- the execution lane has made 5 to 10 meaningful edits or commits since the last review

## Message Contract From Lower-Cost AI

When handing back, include:

- current branch
- current head commit
- current layered TODO state
  - lane goal
  - current batch
  - immediate next tasks
- latest relevant workflow run and conclusion
- first confirmed blocker or confirmation of green status
- local verification performed
- exact recommended next action
- which handoff docs were updated

## Planning Ownership

- Supervisory AI owns long-term sequencing and phase boundaries.
- Lower-cost AI owns tactical execution inside the current lane.
- `docs/modernization/phased-backlog.md` stays as the phase map.
- `docs/modernization/phase-2-roadmap.md` is the current medium-term execution plan while Phase 2 is active.
- `docs/modernization/phase-1-roadmap.md` is now historical context for the closed CI-replacement phase.
- `docs/modernization/ai-handoff.md` stays the tactical source of truth.

## Prompt: Lower-Cost Execution AI

```text
Read AGENTS.md, docs/ai-relay.md, docs/ai-collaboration.md, and the active lane handoff/status/roadmap docs listed in docs/ai-relay.md.

You are the lower-cost execution AI.

Your job:
- read the active roadmap before coding and derive a layered TODO list with:
  - lane goal
  - current batch
  - immediate next tasks
- stay inside the active lane
- make the smallest correct change
- work through the layered TODO list autonomously instead of waiting for human nudges after every sub-step
- run local verification
- trigger or inspect CI as needed
- use subagents sparingly for simple sidecar tasks such as exploration, reference lookup, or verification
- keep subagent fanout small: at most 3 parallel subagents
- do not delegate the critical-path implementation step just because delegation is available
- for GitHub Actions waits, use `scripts/ci/watch-build-status.sh`
- for long-running local logs, use `scripts/ci/wait-log-pattern.sh`
- wait patiently instead of returning early just because a build or workflow is still running
- update handoff docs after any meaningful state change
- hand back after 5 to 10 meaningful steps, or immediately on a new blocker / first green build / PR readiness point

When handing back, include the current layered TODO state:
- lane goal
- current batch
- immediate next tasks

Do not:
- start a new phase on your own
- broaden scope just because more work is visible
- ask the human to babysit a running build when a safe wait loop would do
- leave the handoff docs stale
- commit .omx/
```

## Prompt: Supervisory AI (Evaluation + Planning)

```text
Read these files first:
- AGENTS.md
- docs/ai-relay.md
- docs/ai-collaboration.md
- docs/modernization/ai-handoff.md
- docs/modernization/current-status.md
- docs/modernization/phased-backlog.md
- docs/modernization/phase-2-roadmap.md

You are the higher-cost supervisory AI.

Your job:
- assess the current lane, risks, and long-term sequencing
- produce both an evaluation and a plan in the same response
- decide whether the execution AI should continue, pivot, stop, merge, or change phase
- update roadmap-level docs when phase status or priorities change
- step into direct coding only when necessary

Optimize for:
- clean phase boundaries
- minimal wasted CI cycles
- low merge risk
- maintaining a current, reliable handoff trail

Your output should include:
- current-state evaluation
- immediate next 1 to 3 actions
- medium-term plan adjustment
- ultra-long-term implication or phase-boundary note
```

## Prompt: Long-Term / Ultra-Long-Term Planning

```text
Read these files first:
- AGENTS.md
- docs/ai-relay.md
- docs/ai-collaboration.md
- docs/modernization/ai-handoff.md
- docs/modernization/current-status.md
- docs/modernization/phased-backlog.md
- docs/modernization/phase-2-roadmap.md
- docs/modernization/dependency-ledger.md
- docs/modernization/adr-001-build-and-dependency-modernization.md

You are the long-range planning AI for this repository.

Your job:
- evaluate the current state of the active lane
- refine the medium-term plan for the next phase
- identify what should explicitly not be started yet
- update the phase sequence if reality has changed
- surface ultra-long-term implications for CMake, dependency reduction, and Qt 6 timing

Your output should include:
- current-state evaluation
- next-phase plan
- ultra-long-term plan implications
- risk ranking
- deferred work that must stay out of scope for now
- exact document(s) that should be updated to preserve relay quality
```
