# Serval Endpoint Compatibility Matrix (TPX3 vs MPX3)

## Purpose

Track endpoint-level compatibility between Timepix3 (TPX3) and Medipix3 (MPX3) as exposed by Serval, and identify what can remain shared in a unified areaDetector driver.

Use this document as the primary technical input for the `ADTimePix3` extension vs `ADMediPix3` split decision.

## Legend

- **Status**
  - `same`: endpoint path and semantics are compatible
  - `same-with-guards`: mostly same, but requires detector-family conditionals
  - `different`: requires separate handling path
  - `unknown`: not yet verified
- **Risk**
  - `low`: unlikely to impact architecture decision
  - `medium`: could require targeted refactor
  - `high`: likely split trigger if repeated across core paths

## Detector Identity Baseline

| Detector | MpxType | ChipType | ChipboardId Prefix | Notes |
|---|---:|---|---|---|
| TPX3 | 6 | TPX3 | 41... | Timepix3 profile |
| MPX3 | 5 | MPX3 | 51... | Medipix3 profile |

## Endpoint Matrix

| Area | Endpoint / Operation | TPX3 Result | MPX3 Result | Status | Risk | Notes / Required Action |
|---|---|---|---|---|---|---|
| Identity | `GET /dashboard` | pending | pending | unknown | medium | Confirm identity fields and status semantics |
| Identity | `GET /detector` | pending | pending | unknown | high | Primary source for runtime family detection |
| Config | detector config read | pending | pending | unknown | high | Check field parity, enums, defaults |
| Config | detector config write | pending | pending | unknown | high | Validate write acceptance and error codes |
| Acquisition | measurement start | pending | pending | unknown | high | Compare state transitions and response timing |
| Acquisition | measurement stop | pending | pending | unknown | medium | Validate clean shutdown semantics |
| Acquisition | trigger mode set | pending | pending | unknown | high | Confirm mode set overlap and unsupported options |
| Channels | raw channel config | pending | pending | unknown | medium | Compare path, payload, defaults |
| Channels | image channel config | pending | pending | unknown | high | Critical for AD image path |
| Channels | preview image config | pending | pending | unknown | medium | Important for live UI behavior |
| Channels | histogram config | pending | pending | unknown | high | May be detector-family dependent |
| Streams | `jsonimage` stream schema | pending | pending | unknown | high | Parser compatibility in AD driver |
| Streams | `jsonhisto` stream schema | pending | pending | unknown | high | Split trigger candidate if incompatible |
| Health | detector health endpoint(s) | pending | pending | unknown | medium | Check sensor field differences |
| Versioning | Serval version behavior | pending | pending | unknown | medium | Verify branch logic by version/family |

## Field-Level Diff Checklist (per endpoint)

For each endpoint captured:

- path and method parity
- HTTP status code parity (success + typical failures)
- required request fields
- optional request fields
- response field presence/absence
- response field type differences
- response enum/value-range differences
- semantic differences (same field name, different meaning)

## Suggested Evidence Format

For each endpoint, store raw examples in companion payload map doc and link here:

- TPX3 sample ID: `TPX3-<endpoint>-<timestamp>`
- MPX3 sample ID: `MPX3-<endpoint>-<timestamp>`

Then update matrix row with final status and action.

## Decision Triggers from This Matrix

Consider split toward `ADMediPix3` if either condition occurs:

1. `different` appears in multiple core paths (identity/config/acquisition/streams).
2. `same-with-guards` requires broad, repeated branching that obscures driver behavior.

If most rows become `same` or `same-with-guards` with localized handling, keep a unified driver.

## Work Plan to Complete This Matrix

1. Capture TPX3 baseline responses from emulator + Serval.
2. Capture MPX3 responses under equivalent conditions.
3. Populate matrix status/risk row-by-row.
4. Identify minimum abstraction points in driver.
5. Feed findings into architecture decision record.
