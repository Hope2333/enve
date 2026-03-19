# AI Relay Protocol

This file defines the repository-wide handoff contract for AI coding sessions.

## Required Read Order

Before substantial work, read:

1. `AGENTS.md`
2. `docs/ai-relay.md`
3. The area-specific handoff file for the lane you are touching

Current area-specific handoff:

- Build and dependency modernization: `docs/modernization/ai-handoff.md`

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
- If the active lane changes, update this file so the next AI knows which area-specific handoff to read first.
