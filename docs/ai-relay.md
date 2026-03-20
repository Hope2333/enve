# AI Relay Protocol

This file defines the repository-wide handoff contract for AI coding sessions.

## Required Read Order

Before substantial work, read:

1. `AGENTS.md`
2. `docs/ai-relay.md`
3. `docs/ai-collaboration.md` when multiple AIs are collaborating
4. The area-specific handoff file for the lane you are touching

## Active Lane Registry

- Modernization / CI lane
  - handoff: `docs/modernization/ai-handoff.md`
  - status: `docs/modernization/current-status.md`
  - roadmap: `docs/modernization/phase-4-roadmap.md`

## New Lane Rule

When a new major feature lane starts, do not solve it by pasting a longer prompt. Instead:

1. Create `docs/features/<lane>/ai-handoff.md` from `docs/templates/feature-lane-handoff.template.md`.
2. Create `docs/features/<lane>/roadmap.md` from `docs/templates/feature-roadmap.template.md`.
3. Register the lane here.
4. Point prompts to `docs/ai-relay.md` so the active lane list, not the human clipboard, stays authoritative.

## Required Update Rule

After any meaningful state change, update the relevant handoff docs before stopping. Meaningful changes include:

- a new blocker is confirmed
- a blocker is fixed
- a new branch, commit, PR, or workflow run becomes the active reference
- the recommended next step changes
- a previous assumption is disproved by fresh evidence

## Minimum Handoff Content

Keep the active handoff file current with:

- snapshot time
- active branch and remotes
- current worktree caveats
- latest relevant commit IDs
- latest relevant workflow run IDs and URLs
- latest confirmed blocker
- what was verified locally
- exact next action for the next AI

## Guardrails

- Prefer updating the existing handoff file over creating ad hoc status files.
- Keep prompts and instructions copy-paste ready.
- Do not commit `.omx/`.
- Do not overwrite or reset dirty vendored submodules unless the user explicitly asks.
- If the active lane changes, update this file so the next AI knows which lane docs to read first.
