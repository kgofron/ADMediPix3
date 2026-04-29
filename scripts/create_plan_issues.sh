#!/usr/bin/env bash
set -euo pipefail

# Create milestones and issues for the Medipix3 scope-frozen implementation plan.
# Usage:
#   ./scripts/create_plan_issues.sh
# Optional:
#   REPO=owner/name ./scripts/create_plan_issues.sh

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: gh CLI is not installed."
  exit 1
fi

REPO_ARG=()
if [[ -n "${REPO:-}" ]]; then
  REPO_ARG=(--repo "${REPO}")
fi

ensure_label() {
  local name="$1"
  local color="$2"
  local desc="$3"
  if ! gh api "${REPO_ARG[@]}" repos/{owner}/{repo}/labels --paginate --jq '.[].name' | rg -Fxq "${name}"; then
    gh api "${REPO_ARG[@]}" repos/{owner}/{repo}/labels \
      -X POST \
      -f "name=${name}" \
      -f "color=${color}" \
      -f "description=${desc}" >/dev/null
  fi
}

ensure_milestone() {
  local title="$1"
  if ! gh api "${REPO_ARG[@]}" repos/{owner}/{repo}/milestones --paginate --jq '.[].title' | rg -Fxq "${title}"; then
    gh api "${REPO_ARG[@]}" repos/{owner}/{repo}/milestones \
      -X POST \
      -f "title=${title}" >/dev/null
  fi
}

create_issue() {
  local title="$1"
  local milestone="$2"
  local labels="$3"
  local body="$4"

  if gh issue list "${REPO_ARG[@]}" --state all --search "in:title \"${title}\"" --limit 200 --json title --jq '.[].title' | rg -Fxq "${title}"; then
    echo "Skipping existing issue: ${title}"
    return
  fi

  gh issue create "${REPO_ARG[@]}" \
    --title "${title}" \
    --milestone "${milestone}" \
    --label "${labels}" \
    --body "${body}" >/dev/null
  echo "Created: ${title}"
}

echo "Ensuring labels..."
ensure_label "milestone" "1D76DB" "Milestone planning and tracking"
ensure_label "deliverable" "5319E7" "Project deliverable"
ensure_label "validation" "0E8A16" "Validation and test coverage"
ensure_label "hardware" "FBCA04" "Hardware-backed testing"
ensure_label "risk" "B60205" "Risk tracking and mitigation"

echo "Ensuring milestones..."
ensure_milestone "M0 Scope Freeze & Interfaces"
ensure_milestone "M1 Driver Skeleton & Core Services"
ensure_milestone "M2 Frame Acquisition Pipeline"
ensure_milestone "M3 Preview & Data Model"
ensure_milestone "M4 Hardware Validation & Hardening"
ensure_milestone "M5 Open-Source Release Readiness"

echo "Creating milestone deliverable issues..."
create_issue "[M0] Scope freeze confirmation and interface contract" \
  "M0 Scope Freeze & Interfaces" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M0

## Deliverable
Scope/assumptions note and EPICS interface contract draft

## Description
Freeze v1 scope and align stakeholders on interface boundaries before implementation.

## Acceptance Criteria
- [ ] In-scope/out-of-scope list is explicitly documented
- [ ] ASI confirms or comments on scope
- [ ] Interface contract draft exists (PV naming + capability boundaries)

## Dependencies
- [ ] Scope freeze email to ASI sent
- [ ] Implementation plan is published in docs

## Validation Evidence
Link email thread, review notes, and merged docs.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M0] Define supported EPICS and areaDetector version matrix" \
  "M0 Scope Freeze & Interfaces" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M0

## Deliverable
Supported versions and compatibility notes

## Description
Define target and minimum supported EPICS and areaDetector versions for v1.

## Acceptance Criteria
- [ ] Minimum supported EPICS base version documented
- [ ] areaDetector target version documented
- [ ] Validation environments linked

## Dependencies
- [ ] ASI input on preferred versions

## Validation Evidence
Link docs and sample IOC environment used for verification.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M0] Create v1 out-of-scope register and change-control rule" \
  "M0 Scope Freeze & Interfaces" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M0

## Deliverable
Out-of-scope register with approval path for scope changes

## Description
Protect schedule by making scope boundaries explicit and enforceable.

## Acceptance Criteria
- [ ] Spectral/TDC/TPX4 out-of-scope listed
- [ ] Scope-change process documented
- [ ] Register linked from implementation plan

## Dependencies
- [ ] Milestone 0 scope agreement

## Validation Evidence
Link to register and policy in docs.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M1] Implement Serval driver skeleton and lifecycle state machine" \
  "M1 Driver Skeleton & Core Services" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M1

## Deliverable
Initial driver core with disconnected -> ready -> acquiring lifecycle

## Description
Establish stable runtime lifecycle before deeper feature work.

## Acceptance Criteria
- [ ] IOC compiles and starts with skeleton
- [ ] State transitions are observable
- [ ] Invalid transitions produce clear errors

## Dependencies
- [ ] M0 scope and interface contract

## Validation Evidence
Link logs and test notes for transitions.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M1] Add EPICS status/error signaling surface" \
  "M1 Driver Skeleton & Core Services" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M1

## Deliverable
Health/status PV exposure and logging

## Description
Expose enough runtime state to debug and operate the IOC effectively.

## Acceptance Criteria
- [ ] Connection state exposed in EPICS
- [ ] Last error/cause visible to operator
- [ ] Log messages correlate with state changes

## Dependencies
- [ ] Core lifecycle state machine available

## Validation Evidence
Attach screenshots/log excerpts from simulated error paths.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M1] Introduce Medipix3 specialization boundaries" \
  "M1 Driver Skeleton & Core Services" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M1

## Deliverable
Base vs Medipix3-specific class boundaries

## Description
Separate shared Serval logic from Medipix3-specific behavior for maintainability.

## Acceptance Criteria
- [ ] Shared Serval functionality centralized
- [ ] Medipix3-specific behavior isolated
- [ ] Extension points documented for future families

## Dependencies
- [ ] Driver skeleton in place

## Validation Evidence
Link architecture notes and code references.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M2] Build stable frame ingest path from Serval to EPICS" \
  "M2 Frame Acquisition Pipeline" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M2

## Deliverable
End-to-end frame acquisition path

## Description
Implement reliable frame movement from Serval into EPICS pipeline.

## Acceptance Criteria
- [ ] Frames appear in EPICS consistently
- [ ] No crashes under repeated acquisition loops
- [ ] Error path on upstream stream failure handled

## Dependencies
- [ ] M1 lifecycle and error surfaces

## Validation Evidence
Attach loop-test logs and failure-recovery trace.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M2] Implement acquisition controls (start/stop + key timing/config)" \
  "M2 Frame Acquisition Pipeline" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M2

## Deliverable
Core control PVs wired to runtime behavior

## Description
Deliver minimum operator controls required for production-like operation.

## Acceptance Criteria
- [ ] Start/stop works repeatedly without IOC restart
- [ ] Key timing/config controls applied correctly
- [ ] Unsupported controls fail safely with clear message

## Dependencies
- [ ] Stable frame ingest path

## Validation Evidence
Link IOC interaction logs and quick operator checklist.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M2] Benchmark frame pipeline baseline performance" \
  "M2 Frame Acquisition Pipeline" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M2

## Deliverable
Baseline performance report

## Description
Measure throughput and latency early to reveal bottlenecks.

## Acceptance Criteria
- [ ] FPS/latency/resource metrics captured
- [ ] Test method documented
- [ ] Bottlenecks and next optimizations listed

## Dependencies
- [ ] Acquisition controls implemented

## Validation Evidence
Attach benchmark output and summary table.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M3] Finalize two-layer preview data representation" \
  "M3 Preview & Data Model" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M3

## Deliverable
Final EPICS representation for Medipix3 dual-layer preview

## Description
Choose and lock a representation that is explicit and downstream-friendly.

## Acceptance Criteria
- [ ] Layer identity is explicit
- [ ] Mapping documented for clients/plugins
- [ ] Reviewed/acknowledged with ASI feedback

## Dependencies
- [ ] M2 acquisition data path stable

## Validation Evidence
Attach contract doc and review comments.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M3] Implement preview publishing for single- and dual-layer modes" \
  "M3 Preview & Data Model" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M3

## Deliverable
Functional preview outputs

## Description
Support Medipix3 preview behavior in both single- and dual-layer modes.

## Acceptance Criteria
- [ ] Single-layer preview validated
- [ ] Dual-layer preview validated
- [ ] Metadata is present and correct

## Dependencies
- [ ] Two-layer representation finalized

## Validation Evidence
Attach sample outputs and run logs.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M3] Document areaDetector integration expectations" \
  "M3 Preview & Data Model" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M3

## Deliverable
Integration notes for NDArray/plugin chain

## Description
Document expected behavior to reduce integration ambiguity for users.

## Acceptance Criteria
- [ ] Data-shape semantics documented
- [ ] Plugin assumptions documented
- [ ] Known limitations listed

## Dependencies
- [ ] Preview outputs working

## Validation Evidence
Link integration notes and tested plugin configurations.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

echo "Creating hardware validation issues..."
create_issue "[M4] Run ASI-backed hardware validation campaign" \
  "M4 Hardware Validation & Hardening" \
  "validation,hardware" \
  "$(cat <<'EOF'
## Validation Target
- [ ] ASI test PC
- [ ] ASI detector
- [ ] Loan detector setup

## Test Scope
- [ ] Connection and startup
- [ ] Acquisition start/stop loops
- [ ] Reconnect after disconnect
- [ ] Preview (single-layer and two-layer)
- [ ] Error handling and recovery

## Test Environment
Document firmware, Serval version, EPICS/areaDetector versions, and IOC config used.

## Results
### Passed
- [ ] Item 1

### Failed
- [ ] Item 1

## Defects / Follow-up Issues
- #issue

## Go/No-Go Recommendation
- [ ] Go
- [ ] Conditional go
- [ ] No-go

Rationale:
EOF
)"

create_issue "[M4] Validate reconnect and interruption recovery behavior" \
  "M4 Hardware Validation & Hardening" \
  "validation,hardware" \
  "$(cat <<'EOF'
## Validation Target
- [ ] ASI test PC
- [ ] ASI detector

## Test Scope
- [ ] Reconnect after disconnect
- [ ] Stream interruption recovery
- [ ] Operator-facing diagnostics and recoverability

## Test Environment
Document firmware, Serval version, EPICS/areaDetector versions, and IOC config used.

## Results
### Passed
- [ ] Item 1

### Failed
- [ ] Item 1

## Defects / Follow-up Issues
- #issue

## Go/No-Go Recommendation
- [ ] Go
- [ ] Conditional go
- [ ] No-go

Rationale:
EOF
)"

create_issue "[M4] Triage and close release-candidate defects" \
  "M4 Hardware Validation & Hardening" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M4

## Deliverable
RC defect list and dispositions

## Description
Ensure release blockers are resolved or explicitly accepted before release prep.

## Acceptance Criteria
- [ ] Critical/high defects resolved or explicitly waived
- [ ] Remaining defects linked to follow-up issues
- [ ] Go/conditional-go recommendation posted

## Dependencies
- [ ] Hardware validation campaign completed

## Validation Evidence
Link defect tracker, final validation summary, and approval note.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

echo "Creating release-readiness issues..."
create_issue "[M5] Publish install/build/runbook documentation" \
  "M5 Open-Source Release Readiness" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M5

## Deliverable
Operator and developer docs

## Description
Provide reproducible setup and operational guidance for external users.

## Acceptance Criteria
- [ ] Clean setup from scratch is reproducible
- [ ] Runtime troubleshooting section included
- [ ] Example startup config included

## Dependencies
- [ ] M4 hardening outcomes captured

## Validation Evidence
Attach docs links and smoke-test notes from clean environment.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M5] Prepare public release tag and notes" \
  "M5 Open-Source Release Readiness" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M5

## Deliverable
First public release package

## Description
Publish v1 release with explicit scope, known limits, and links to docs.

## Acceptance Criteria
- [ ] Release notes reflect v1 scope
- [ ] Known limitations are explicit
- [ ] Artifacts and docs are linked

## Dependencies
- [ ] Documentation finalized

## Validation Evidence
Link release draft and pre-release checklist.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

create_issue "[M5] Finalize contributor workflow (templates + contribution guide)" \
  "M5 Open-Source Release Readiness" \
  "milestone,deliverable" \
  "$(cat <<'EOF'
## Milestone
M5

## Deliverable
Maintainer-friendly contribution workflow

## Description
Enable sustainable community contributions post-release.

## Acceptance Criteria
- [ ] Issue templates active and tested
- [ ] Contribution guide present
- [ ] Basic triage labels documented

## Dependencies
- [ ] Issue templates merged

## Validation Evidence
Attach links to template files and contribution docs.

## Out of Scope Reminder
- Spectral mode
- TDC
- Timepix3/Timepix4 runtime support
EOF
)"

echo "Creating risk issues..."
create_issue "[RISK] Scope creep into spectral/TDC" \
  "M0 Scope Freeze & Interfaces" \
  "risk" \
  "$(cat <<'EOF'
## Risk Statement
Scope may expand into spectral mode or TDC before v1 is stable.

## Impact
- [ ] Low
- [x] Medium
- [ ] High

## Likelihood
- [ ] Low
- [x] Medium
- [ ] High

## Mitigation Plan
- [ ] Enforce scope gate in planning and reviews
- [ ] Require explicit approval for scope changes

## Trigger / Early Warning Signal
Feature requests or implementation tasks for spectral/TDC appear in active sprint.

## Owner
@owner

## Review Date
2026-05-15
EOF
)"

create_issue "[RISK] Hardware access delays with ASI setup" \
  "M4 Hardware Validation & Hardening" \
  "risk" \
  "$(cat <<'EOF'
## Risk Statement
Delays in access to ASI hardware environment may block validation and hardening.

## Impact
- [ ] Low
- [ ] Medium
- [x] High

## Likelihood
- [ ] Low
- [x] Medium
- [ ] High

## Mitigation Plan
- [ ] Book test windows early
- [ ] Keep loan-detector fallback available

## Trigger / Early Warning Signal
Missed validation window or no confirmed test schedule for >1 week.

## Owner
@owner

## Review Date
2026-05-22
EOF
)"

create_issue "[RISK] Two-layer preview model mismatch with downstream clients" \
  "M3 Preview & Data Model" \
  "risk" \
  "$(cat <<'EOF'
## Risk Statement
Preview data model may be unclear or incompatible with expected client/plugin usage.

## Impact
- [ ] Low
- [x] Medium
- [ ] High

## Likelihood
- [ ] Low
- [x] Medium
- [ ] High

## Mitigation Plan
- [ ] Finalize and document preview contract in M3
- [ ] Validate with representative downstream consumers

## Trigger / Early Warning Signal
Repeated changes to preview schema or plugin wiring after M3 freeze.

## Owner
@owner

## Review Date
2026-05-29
EOF
)"

create_issue "[RISK] Frame-path performance below operational needs" \
  "M2 Frame Acquisition Pipeline" \
  "risk" \
  "$(cat <<'EOF'
## Risk Statement
Frame throughput/latency may be insufficient for real operational use.

## Impact
- [ ] Low
- [x] Medium
- [ ] High

## Likelihood
- [ ] Low
- [x] Medium
- [ ] High

## Mitigation Plan
- [ ] Benchmark in M2 with realistic configs
- [ ] Tune buffering and data path hotspots

## Trigger / Early Warning Signal
Observed drops/latency spikes during sustained acquisition tests.

## Owner
@owner

## Review Date
2026-05-22
EOF
)"

create_issue "[RISK] EPICS/areaDetector version mismatch in community adoption" \
  "M5 Open-Source Release Readiness" \
  "risk" \
  "$(cat <<'EOF'
## Risk Statement
Users may run unsupported EPICS/areaDetector combinations causing adoption issues.

## Impact
- [ ] Low
- [x] Medium
- [ ] High

## Likelihood
- [ ] Low
- [x] Medium
- [ ] High

## Mitigation Plan
- [ ] Publish supported version matrix early
- [ ] Validate representative combinations and document limitations

## Trigger / Early Warning Signal
Issue reports tied to environment version mismatches increase.

## Owner
@owner

## Review Date
2026-06-05
EOF
)"

echo "Done. Milestones and issues are ready."
