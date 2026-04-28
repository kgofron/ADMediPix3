# Medipix3 EPICS Support Architecture

## Purpose

Define an implementation strategy for EPICS support of ASI Medipix3 detectors, and decide whether to:

- extend existing `ADTimePix3`, or
- create a separate `ADMediPix3` areaDetector IOC/driver.

This document evaluates architecture across:

1. Emulator layer (`/epics/iocs/emulator`)
2. Serval layer (`/epics/iocs/serval`)
3. areaDetector driver/IOC layer (`ADTimePix3` vs `ADMediPix3`)

## Decision Summary (Current Recommendation)

Start with a **single-codebase approach** by extending `ADTimePix3` to support Medipix3.

Defer a separate `ADMediPix3` split unless compatibility analysis and prototype work show meaningful protocol or behavior divergence.

### Why this is the current best option

- Both detectors use Serval and likely share large portions of control/data flow.
- Existing `ADTimePix3` already contains robust infrastructure (REST/JSON integration, stream handling, reconnect logic, areaDetector plugin integration).
- Early split would duplicate maintenance burden before proving necessity.

## Known Detector Identity Signals

From local detector metadata:

- Medipix3 example:
  - `MpxType = 5`
  - `ChipType = "MPX3"`
  - `ChipboardId` prefix appears as `51...`
  - Firmware default observed from emulator help: `22083000`

- Timepix3 example:
  - `MpxType = 6`
  - `ChipType = "TPX3"`
  - `ChipboardId` prefix appears as `41...`
  - Firmware default observed from emulator help: `25102015`

These fields should be used as runtime detector-family discriminators in the IOC/driver.

## Scope and Constraints

- Target stack is Linux EPICS + areaDetector.
- Support real detector and emulator workflows.
- Keep operator workflow stable (PVs, screens, plugin chains) unless behavior requires detector-specific variants.
- Prioritize maintainability and testability over premature repo split.

## Architecture Layers

## 1) Emulator Layer

### Inputs

- Medipix3 emulator: `mpx3Emulator-4.1.5.jar`
- Timepix3 emulator: `tpx3Emulator-4.1.5.jar`

### Observed CLI differences (important)

- `tpx3Emulator` exposes `--chipboardId` and replay/hit-rate/TDC-specific options.
- `mpx3Emulator` exposes options like `--chipMask`, `--megapixel`, and packet loss/fraction toggles, but does not show TPX3 `--chipboardId` option in help.

### Plan

- Create standardized start scripts for both emulators with aligned network and deterministic settings.
- Add a minimal compatibility check that validates detector identity surfaced via Serval (`MpxType`, `ChipType`, `ChipboardId`).
- Store canonical emulator profiles for reproducible test runs (dev + CI).

## 2) Serval Layer

### Key question

Is Medipix3 exposed through equivalent REST resources and stream schemas as Timepix3?

### Plan

- Compare response payloads for core endpoints used by IOC:
  - dashboard/status
  - detector metadata/config
  - measurement config/control
  - channel/write settings (raw/img/preview/hist)
- Build a compatibility matrix:
  - common fields
  - optional fields
  - detector-specific fields
  - semantic differences (same field, different meaning/range)
- Validate stream formats required by IOC (`jsonimage`, `jsonhisto`, raw).

### Outcome needed

- Clear list of what is shared and what requires detector-family branches.

## 3) areaDetector Driver/IOC Layer

### Baseline design

Implement Medipix3 in existing `ADTimePix3` first, via a detector-family abstraction.

### Proposed abstraction

- Add `DetectorFamily` enum:
  - `TPX3`
  - `MPX3`
  - `UNKNOWN`
- Determine family at runtime from Serval metadata:
  - `MpxType`
  - `ChipType`
  - `ChipboardId` prefix
- Route detector-specific behavior through focused helper modules:
  - default config values
  - capability flags
  - payload validation
  - UI label/profile selection

### Keep shared core unchanged where possible

- HTTP client and JSON parsing infrastructure
- acquisition state management
- reconnect/recovery flows
- areaDetector plugin callbacks
- IOC startup patterns and common DB templates

## Reuse Strategy by Component

### High-confidence reuse

- Core EPICS/asyn/ADDriver scaffolding
- Connection and status monitoring framework
- Stream worker architecture and plugin delivery model
- Existing IOC deployment model in `/epics/iocs/serval`

### Likely detector-specific extensions

- Detector capability detection and validation
- Detector-default channel/config values
- Potential trigger/timing option handling if TPX3-only features exist

### Candidate split points (if needed later)

- Detector-specific OPI screens
- Detector-specific DB templates with diverging semantics
- Separate driver module/repo only if shared core is no longer coherent

## Decision Gates: When to Create `ADMediPix3`

Create separate `ADMediPix3` only if one or more of these are true after prototype:

1. REST/resource and config payload divergence is substantial (sustained high conditional complexity).
2. Stream transport/schema handling diverges enough to require separate parsing/data paths.
3. Acquisition state machine behavior differs significantly (trigger, counters, timing, health semantics).
4. Shared PV model becomes ambiguous or unstable for operators.
5. Unified test matrix becomes brittle and blocks release cadence.

If these are not true, keep a unified driver and publish Medipix3 support in `ADTimePix3`.

## Phased Execution Plan

## Phase 0: Setup and Artifact Capture (1-2 days)

- Collect representative Serval payloads for both detector families.
- Capture emulator launch profiles and expected identity outputs.
- Define baseline IOC startup scripts for side-by-side comparison.

Deliverables:

- `docs/compatibility/serval-payload-map.md`
- `docs/compatibility/emulator-profiles.md`

## Phase 1: Compatibility Inventory (2-4 days)

- Build field-by-field endpoint compatibility matrix.
- Identify required detector-specific branches.
- Confirm stream format parity and feature availability.

Deliverables:

- `docs/compatibility/serval-endpoint-matrix.md`
- initial risk list

## Phase 2: Unified Driver Prototype (4-7 days)

- Add `DetectorFamily` runtime detection.
- Introduce minimal strategy hooks for family-specific behavior.
- Keep common codepath default.

Deliverables:

- prototype branch with MPX3 detector identity and basic control
- regression results against TPX3 emulator

## Phase 3: IOC/DB/OPI Profile Layer (2-4 days)

- Add Medipix profile macros/startup scripts.
- Duplicate only truly detector-specific UI/DB pieces.
- Preserve shared naming where semantics are identical.

Deliverables:

- `iocMediPix` startup profile (or equivalent macro flavor)
- operator notes for profile selection

## Phase 4: Validation and Split Decision (2-3 days)

- Run acceptance tests on both emulators and available hardware.
- Evaluate complexity metrics and maintenance cost.
- Apply decision gates for final split/no-split conclusion.

Deliverables:

- architecture decision record (ADR): unified or split
- prioritized backlog for production hardening

## Validation Matrix

Minimum checks for each detector family (TPX3, MPX3):

- connect/disconnect/reconnect behavior
- acquisition start/stop in supported modes
- image/preview stream reliability
- histogram behavior (if supported by detector family)
- file plugin output validity (HDF5/TIFF/PVA as configured)
- health/status PV correctness
- regression of existing TPX3 workflows

## Risks and Mitigations

- Risk: hidden Serval semantic differences not visible in static payload diff.
  - Mitigation: include behavioral tests, not only schema checks.

- Risk: TPX3-only features leak into MPX3 defaults and confuse users.
  - Mitigation: capability flags + family-specific default profiles.

- Risk: premature fork increases maintenance load.
  - Mitigation: enforce decision gates before splitting repository/driver.

## Repository/Project Mapping

- Emulator development and profiles:
  - `/epics/iocs/emulator`
  - reference repository: <https://github.com/kgofron/emulator>

- Serval integration and endpoint behavior:
  - `/epics/iocs/serval`
  - reference repository: <https://github.com/kgofron/serval>

- areaDetector IOC/driver baseline:
  - `ADTimePix3`
  - reference repository: <https://github.com/areaDetector/ADTimePix3>

## Open Questions

1. Which Serval endpoints/fields are guaranteed stable across MPX3 and TPX3?
2. Is histogram/ToF path fully applicable to MPX3, partially applicable, or unsupported?
3. Are any trigger modes detector-family-specific at the Serval API level?
4. Should operator PV naming remain TPX3-prefixed for compatibility, or adopt family-neutral aliases?
5. What minimum hardware test set is required before production rollout?

## Initial Recommendation for Implementation Order

1. Build compatibility matrix (emulator + Serval payload/behavior).
2. Implement detector-family detection in `ADTimePix3`.
3. Add minimal MPX3 profile support in IOC startup/UI.
4. Run dual-family regression.
5. Make split/no-split decision with evidence.

This sequence minimizes risk, preserves momentum, and keeps the option open to create `ADMediPix3` only if justified by measured divergence.
