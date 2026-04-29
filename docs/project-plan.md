# Medipix3 EPICS Project Plan

> Note: The scope-frozen execution plan is tracked in `docs/implementation-plan.md`. This document captures the earlier compatibility/discovery and architecture-decision track.

## Goal

Deliver production-ready Medipix3 EPICS support with evidence-based decision on:

- unified `ADTimePix3` extension, or
- split into separate `ADMediPix3`.

## Planning Assumptions

- Both detector families use Serval.
- Compatibility must be validated at emulator, REST/JSON API, and stream layers.
- Final split/no-split decision is made after prototype and regression.

## Phases, Effort, and Deliverables

## Phase 1: Interface Inventory (1-2 days)

### Scope

- Diff TPX3 vs MPX3 emulator options and behavior.
- Compare Serval identity/config payloads (`/dashboard`, `/detector`, config read/write).
- Build common vs detector-specific field map.

### Deliverables

- updated `docs/compatibility/serval-payload-map.md`
- initial `docs/compatibility/serval-endpoint-matrix.md` statuses

## Phase 2: Emulator Parity Harness (2-3 days)

### Scope

- Standardize emulator launch profiles and scripts.
- Add lightweight identity contract checks (`MpxType`, `ChipType`, `ChipboardId`).
- Make local/CI runs reproducible.

### Deliverables

- completed `docs/compatibility/emulator-profiles.md`
- profile scripts and baseline logs

## Phase 3: Serval Compatibility Probe (2-4 days)

### Scope

- Validate endpoint and version behavior for both families.
- Confirm parser assumptions in `ADTimePix3` inputs.
- Catalog optional/unsupported detector-family fields.

### Deliverables

- endpoint matrix updated to near-final
- list of required abstraction points in IOC/driver

## Phase 4: Unified Driver Prototype in `ADTimePix3` (4-7 days)

### Scope

- Add `DetectorFamily` detection from Serval metadata.
- Implement targeted strategy hooks (defaults/validation/capabilities).
- Preserve shared pipelines (connection, acquisition, TCP streams, plugins, masks).
- Add IOC profile/macros for Medipix flavor.

### Deliverables

- prototype branch with MPX3 basic support
- TPX3 regression report (no functional regressions)

## Phase 5: IOC/DB/OPI Profile Split Without Codebase Split (2-4 days)

### Scope

- Add Medipix startup/profile files and macro sets.
- Reuse common templates where semantics are shared.
- Duplicate only detector-specific UI labels/options.

### Deliverables

- initial Medipix IOC boot profile
- operator mapping notes (TPX3 vs MPX3 profile selection)

## Phase 6: Validation and Final Architecture Decision (2-3 days)

### Scope

- Execute test suite across TPX3 and MPX3 emulators (and hardware where available).
- Measure divergence/conditional complexity and maintenance risk.
- Apply go/no-go criteria for `ADMediPix3`.

### Deliverables

- final decision record: unified vs split
- prioritized hardening backlog

## Total Estimated Effort

- **13-23 working days** (depends on divergence found and hardware access).

## Milestones

1. **M1 (end Phase 2):** reproducible emulator baseline and identity checks.
2. **M2 (end Phase 3):** compatibility matrix with clear abstraction needs.
3. **M3 (end Phase 4):** working unified prototype in `ADTimePix3`.
4. **M4 (end Phase 6):** final split/no-split decision with evidence.

## Risks and Mitigations

- Hidden behavioral differences despite similar schemas.
  - Mitigation: include behavioral acquisition/stream tests, not just static diffs.
- TPX3 regressions during MPX3 onboarding.
  - Mitigation: run TPX3 regression after each prototype increment.
- Premature repo split.
  - Mitigation: enforce evidence-based go/no-go criteria at Phase 6.

## Exit Criteria

Project is considered complete when:

1. Medipix3 IOC workflow is validated end-to-end,
2. TPX3 regression baseline remains stable,
3. architecture decision (unified vs split) is documented and justified by measured evidence.
