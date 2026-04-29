# Medipix3 EPICS Implementation Plan (Scope-Frozen v1)

## Purpose

This document captures the execution plan after scope alignment with ASI for an open-source Medipix3 EPICS driver effort.

## Scope

### In Scope (v1)

- Medipix3 2x2 detector support
- Frame-based acquisition path
- Basic detector configuration and status exposure to EPICS
- Preview image support, including Medipix3 two-layer behavior
- Hardware validation with ASI test setup

### Out of Scope (v1)

- Medipix3 spectral mode (2x2-as-1 with 8 thresholds)
- TDC functionality
- Timepix3/Timepix4 runtime support

## Architecture Direction

Use one Serval-oriented codebase with shared core components and Medipix3-specific specializations, instead of fully separate code paths per chip family.

Indicative structure:

- `ServalBase` for connection/state/acquisition lifecycle
- `ServalDacs` with `Medipix3Dacs` specialization
- `ServalPreview` with `Mpx3Preview` specialization

## Milestones and Deliverables

## Milestone 0: Scope Freeze and Interfaces (Week 0-1)

### Deliverables

- scope and assumptions note acknowledged by stakeholders
- EPICS interface contract draft (PV naming and feature boundaries)
- explicit v1 out-of-scope register

## Milestone 1: Driver Skeleton and Core Services (Week 1-2)

### Deliverables

- compiling IOC with initial driver skeleton
- connection/state machine (`disconnected -> ready -> acquiring`)
- error handling and status signaling surface in EPICS

## Milestone 2: Frame Acquisition Pipeline (Week 2-4)

### Deliverables

- stable frame ingest path from Serval to EPICS
- start/stop acquisition controls and core timing/config controls
- baseline performance report (fps, latency, resource usage)

## Milestone 3: Preview and Data Model Finalization (Week 4-5)

### Deliverables

- finalized two-layer preview representation in EPICS
- metadata semantics documented for downstream users/plugins
- compatibility notes for areaDetector pipeline integration

## Milestone 4: Hardware Validation and Hardening (Week 5-7)

### Deliverables

- integrated testing on ASI test PC and detector
- reconnect/fault/interruption test evidence
- release-candidate defect list with resolutions or tracked follow-ups

## Milestone 5: Open-Source Release Readiness (Week 7-8)

### Deliverables

- public release tag and release notes
- install/build/runbook documentation
- issue templates and contribution guidelines

## Risk Register

| Risk | Impact | Likelihood | Mitigation | Owner |
| --- | --- | --- | --- | --- |
| Scope creep into spectral/TDC | schedule slip | medium | strict v1 scope gate and change control | project leads |
| Hardware access delays | integration blocked | medium | pre-book ASI sessions; fallback to loan detector | project leads + ASI |
| Two-layer preview model mismatch | client/plugin rework | medium | finalize preview contract before hardening | driver team |
| Serval behavior drift | runtime instability | medium | adapter boundaries, validation checks, robust diagnostics | driver team |
| Frame-path performance gaps | dropped frames | medium | benchmark early and tune buffering strategy | driver team |
| EPICS version mismatch in community | adoption friction | medium | publish supported matrix and tested versions | driver team |

## Acceptance Criteria (v1)

- reproducible frame-based acquisition for Medipix3 2x2
- stable repeated start/stop and reconnect behavior without IOC restart
- documented and validated two-layer preview handling
- hardware validation evidence from ASI-backed setup
- public documentation sufficient for third-party setup
