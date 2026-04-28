# Serval Payload Map and Evidence Log (TPX3 vs MPX3)

## Purpose

Maintain raw and normalized payload evidence from Serval for Timepix3 and Medipix3 under equivalent test conditions.

This file complements `serval-endpoint-matrix.md` by storing concrete examples used to classify compatibility.

## Capture Conventions

- Sample IDs:
  - `TPX3-<endpoint>-<YYYYMMDD-HHMMSS>`
  - `MPX3-<endpoint>-<YYYYMMDD-HHMMSS>`
- Store each sample as:
  - request metadata
  - response status code
  - key fields
  - raw payload reference (inline or external file path)
- Keep TPX3 and MPX3 captures paired by scenario.

## Test Context Template

Fill this header for each capture set:

- Serval version:
- Emulator profile:
- Detector family:
- IOC version/branch:
- Host/network notes:
- Timestamp window:

## Endpoint Evidence Sections

## 1) Dashboard / Status

### TPX3 Sample

- Sample ID: `pending`
- Request: `GET /dashboard` (or equivalent)
- HTTP status: `pending`
- Key fields:
  - detector connected:
  - health summary:
  - version fields:
- Raw payload reference: `pending`

### MPX3 Sample

- Sample ID: `pending`
- Request: `GET /dashboard` (or equivalent)
- HTTP status: `pending`
- Key fields:
  - detector connected:
  - health summary:
  - version fields:
- Raw payload reference: `pending`

### Diff Notes

- pending

## 2) Detector Metadata / Identity

### TPX3 Sample

- Sample ID: `pending`
- Request: `GET /detector` (or equivalent)
- HTTP status: `pending`
- Key fields:
  - `MpxType`:
  - `ChipType`:
  - `ChipboardId`:
  - `FirmwareVersion`:
  - `PixCount`:
  - `NumberOfChips`:
- Raw payload reference: `pending`

### MPX3 Sample

- Sample ID: `pending`
- Request: `GET /detector` (or equivalent)
- HTTP status: `pending`
- Key fields:
  - `MpxType`:
  - `ChipType`:
  - `ChipboardId`:
  - `FirmwareVersion`:
  - `PixCount`:
  - `NumberOfChips`:
- Raw payload reference: `pending`

### Diff Notes

- pending

## 3) Detector Configuration Read

### TPX3 Sample

- Sample ID: `pending`
- Request: config read endpoint
- HTTP status: `pending`
- Key fields:
  - trigger mode:
  - exposure/period:
  - channel enables:
- Raw payload reference: `pending`

### MPX3 Sample

- Sample ID: `pending`
- Request: config read endpoint
- HTTP status: `pending`
- Key fields:
  - trigger mode:
  - exposure/period:
  - channel enables:
- Raw payload reference: `pending`

### Diff Notes

- pending

## 4) Detector Configuration Write

### TPX3 Sample

- Sample ID: `pending`
- Request: config write endpoint
- HTTP status: `pending`
- Request keys used:
- Response keys returned:
- Raw payload reference: `pending`

### MPX3 Sample

- Sample ID: `pending`
- Request: config write endpoint
- HTTP status: `pending`
- Request keys used:
- Response keys returned:
- Raw payload reference: `pending`

### Diff Notes

- pending

## 5) Acquisition Start/Stop

### TPX3 Samples

- Start sample ID: `pending`
- Stop sample ID: `pending`
- HTTP status codes:
- Timing observations:
- Raw payload reference: `pending`

### MPX3 Samples

- Start sample ID: `pending`
- Stop sample ID: `pending`
- HTTP status codes:
- Timing observations:
- Raw payload reference: `pending`

### Diff Notes

- pending

## 6) Channel and Stream Config

Include raw/img/preview/hist configuration endpoints used by IOC.

### TPX3 Sample Set

- Sample IDs: `pending`
- Formats observed:
  - raw:
  - image:
  - preview:
  - histogram:
- Raw payload reference: `pending`

### MPX3 Sample Set

- Sample IDs: `pending`
- Formats observed:
  - raw:
  - image:
  - preview:
  - histogram:
- Raw payload reference: `pending`

### Diff Notes

- pending

## 7) Stream Schema Snapshots

Capture first valid frames/metadata for each stream the IOC consumes.

### TPX3

- `jsonimage` schema summary:
- `jsonhisto` schema summary:
- raw stream metadata summary:
- References:

### MPX3

- `jsonimage` schema summary:
- `jsonhisto` schema summary:
- raw stream metadata summary:
- References:

### Diff Notes

- pending

## Normalization Rules

When comparing payloads:

- ignore ordering differences in JSON objects
- normalize numeric types where appropriate (`int` vs `float` formatting)
- distinguish missing fields from explicit null/empty values
- treat same-named fields as different if semantic meaning differs

## Findings Log

Use this section to record concise compatibility outcomes.

- `YYYY-MM-DD`: initial baseline created; no paired captures yet.

## Link Back to Matrix

After each endpoint pair is analyzed:

1. update this payload map with evidence,
2. update row status in `serval-endpoint-matrix.md`,
3. list required IOC/driver action in matrix notes.

This keeps evidence, classification, and implementation decisions synchronized.
