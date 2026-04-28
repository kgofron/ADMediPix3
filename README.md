# Medipix3 EPICS Support Planning

## Objective

Plan EPICS areaDetector support for Medipix3 while minimizing risk and duplicated maintenance.

Primary decision:

- extend `ADTimePix3` to support Medipix3, or
- create a separate `ADMediPix3`.

## Current Recommendation

Start by extending `ADTimePix3` (single codebase), with detector-family profiling at runtime:

- `TPX3` vs `MPX3` identified from Serval metadata (`MpxType`, `ChipType`, `ChipboardId`).
- keep one driver binary initially.
- keep one IOC codebase with profile/macros (Timepix vs Medipix flavor).

Only split into `ADMediPix3` if measured divergence justifies it.

## Go/No-Go Criteria for Separate `ADMediPix3`

Create separate `ADMediPix3` only if prototype evidence shows one or more of:

1. REST resources/payloads diverge significantly (roughly >20-30% in core paths).
2. Stream schemas/parsers are incompatible (`jsonimage`, `jsonhisto`, raw).
3. Acquisition model diverges (trigger/timing/counters/state-machine behavior).
4. PV semantics diverge enough that shared templates become confusing/unstable.
5. Emulator + test matrix becomes unmanageable in one module.

If these are not true, keep unified implementation in `ADTimePix3`.

## Documents

- Architecture and decision framework:
  - `docs/medipix3-epics-architecture.md`
- Serval endpoint compatibility matrix:
  - `docs/compatibility/serval-endpoint-matrix.md`
- Emulator profiles and regression scenarios:
  - `docs/compatibility/emulator-profiles.md`
- Serval payload evidence log:
  - `docs/compatibility/serval-payload-map.md`
- Phased effort/timeline:
  - `docs/project-plan.md`

## Repositories in Scope

- Emulator: <https://github.com/kgofron/emulator>
- Serval IOC/integration: <https://github.com/kgofron/serval>
- areaDetector baseline driver: <https://github.com/areaDetector/ADTimePix3>
