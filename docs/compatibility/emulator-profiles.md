# Emulator Profiles and Test Scenarios (TPX3 vs MPX3)

## Purpose

Define reproducible emulator launch profiles for Timepix3 and Medipix3 to support compatibility validation, regression testing, and IOC bring-up.

This document standardizes how to run emulators so behavior comparisons are meaningful.

## Emulator Binaries

- Timepix3: `tpx3Emulator-4.1.5.jar`
- Medipix3: `mpx3Emulator-4.1.5.jar`

## Known CLI Characteristics

### TPX3 Emulator

- Supports options including:
  - `--firmwareVersion` (default observed: `25102015`)
  - `--chipboardId` (default observed: `41000039`)
  - `--net`
  - `--replay`
  - `--hitRate`
  - `--tdc`

### MPX3 Emulator

- Supports options including:
  - `--firmwareVersion` (default observed: `22083000`)
  - `--megapixel`
  - `--net`
  - `--chipMask`
  - `--cornerText`
  - `--loss`
  - `--frac`
  - `--omr0`

## Identity Expectations

After Serval connects to emulator-backed detector:

- TPX3 expected identity:
  - `MpxType = 6`
  - `ChipType = TPX3`
  - `ChipboardId` prefix `41...`

- MPX3 expected identity:
  - `MpxType = 5`
  - `ChipType = MPX3`
  - `ChipboardId` prefix `51...`

## Standard Profiles

## Profile A: Local Deterministic Bring-Up (default)

Goal: simple local validation with lowest variability.

### TPX3

`java -jar tpx3Emulator-4.1.5.jar --net=0`

### MPX3

`java -jar mpx3Emulator-4.1.5.jar --net=0 --chipMask=15`

Expected outcome:

- Serval can discover detector.
- IOC can connect and read identity metadata.

## Profile B: Stress / Fault Injection

Goal: validate driver resilience and recovery logic.

### TPX3

- vary `--hitRate` (e.g., low/nominal/high)
- optional replay path via `--replay`

### MPX3

- inject packet/data issues:
  - `--loss`
  - `--frac`
  - `--omr0`

Expected outcome:

- IOC remains stable.
- errors are surfaced via status PVs without crash.

## Profile C: Throughput Characterization

Goal: compare data-path behavior under higher sustained rates.

### TPX3

- increase `--hitRate` progressively

### MPX3

- enable all chips and compare behavior under nominal + stressed packet conditions

Expected outcome:

- identify if stream parsing/performance assumptions are detector-family dependent.

## Launch Script Recommendations

Create wrapper scripts in emulator workspace:

- `run_tpx3_profile_a.sh`
- `run_mpx3_profile_a.sh`
- `run_tpx3_profile_b.sh`
- `run_mpx3_profile_b.sh`

Each script should:

- print full command line
- print timestamp + host
- print intended profile ID
- write logs to profile-specific file

## Capture Checklist (per run)

- emulator command and full args
- Serval version
- endpoint payload captures (`/dashboard`, `/detector`, config)
- IOC startup config/macros
- observed connection/acquisition behavior
- error/warning logs (if any)

## Regression Matrix

| Profile | Detector | Serval Connect | IOC Connect | Acquire Start/Stop | Stream OK | Notes |
|---|---|---|---|---|---|---|
| A | TPX3 | pending | pending | pending | pending | |
| A | MPX3 | pending | pending | pending | pending | |
| B | TPX3 | pending | pending | pending | pending | |
| B | MPX3 | pending | pending | pending | pending | |
| C | TPX3 | pending | pending | pending | pending | |
| C | MPX3 | pending | pending | pending | pending | |

## IOC Integration Notes

- Keep IOC startup consistent between detector families except detector-specific macro defaults.
- Use same plugin chain while validating architecture choice.
- Only introduce detector-specific startup files when needed for semantic differences.

## Exit Criteria

This document is complete when:

1. all standard profiles are scripted and reproducible,
2. identity expectations are validated for both families,
3. regression matrix is populated for core flows,
4. differences are fed into Serval endpoint matrix and architecture decision.
