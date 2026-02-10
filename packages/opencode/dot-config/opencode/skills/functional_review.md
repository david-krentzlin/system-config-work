# Skill: Functional Review & Intent Verification

## Objective
Verify that the change implements the **intended behavior** correctly and completely, as defined by explicit or derived acceptance criteria, and that it meets a clear definition of done.

This skill focuses on *what the change is supposed to do*, not just what the code currently does.

---

## Core Principle
**No functional review can be complete without a shared understanding of intent.**

If intent is unclear, incomplete, or contradictory, the review must pause and request clarification before proceeding to detailed testing.

---

## Inputs (in priority order)
1. Linked issue / ticket (preferred)
2. PR title and description
3. Commit messages
4. Code diffs (as a fallback signal only)

---

## Phase 1: Intent Discovery

### Responsibilities
- Identify the **primary goal** of the change
- Identify **in-scope behavior**
- Identify **explicitly out-of-scope behavior**
- Detect ambiguous, underspecified, or conflicting intent

### Methods
- Read the linked issue or specification
- If no issue exists:
  - Infer intent from PR title and description
  - Treat inferred intent as *tentative*

### Mandatory Clarification
If any of the following are true, you MUST ask clarifying questions **before** finalizing acceptance criteria:
- Expected behavior is implicit or vague
- Success conditions are not measurable
- Edge cases are not addressed
- Backward compatibility expectations are unclear

Use Conventional Comments:
- `question(functional):` for clarification requests

---

## Phase 2: Acceptance Criteria Definition

### Objective
Translate intent into **explicit, testable acceptance criteria**.

Acceptance Criteria must be:
- Observable
- Verifiable
- Unambiguous
- Minimal but complete

### Responsibilities
- Extract existing acceptance criteria from the issue (if present)
- If missing or incomplete, **propose acceptance criteria**
- Validate acceptance criteria against change scope

### Format
Acceptance Criteria should be written as a checklist, for example:

- Given X, when Y, then Z
- Error case A returns B
- Existing behavior C remains unchanged
- Performance characteristic D does not regress

### Output
- A clearly enumerated list of acceptance criteria
- Mapping from acceptance criteria → tests (existing or proposed)

---

## Phase 3: Definition of Done (DoD)

### Objective
Establish what “done” means for this change beyond basic correctness.

### Responsibilities
- Identify an existing Definition of Done from the repo/team (if any)
- If none exists, **derive a contextual Definition of Done** for this change

### Typical DoD Elements
Depending on the system, this may include:
- All acceptance criteria satisfied
- Required tests added and passing
- No known regressions introduced
- Performance within agreed thresholds
- Security considerations addressed
- Documentation updated (if applicable)
- No flaky or quarantined tests introduced

### Output
- Explicit Definition of Done for this change
- Gaps between current state and DoD

---

## Phase 4: Verification Against AC & DoD

### Responsibilities
- Verify each acceptance criterion:
  - Covered by an automated test, or
  - Explicitly justified as out-of-scope
- Identify missing or weak coverage
- Validate behavior against edge cases implied by AC

### Evidence Requirements
For each acceptance criterion:
- Test name(s) or command(s), OR
- Reasoned explanation if not testable

---

## Severity & Commenting Guidance

Use Conventional Comments consistently:

- `blocking(functional):`
  - Acceptance criterion not met
  - Critical behavior untested or incorrect
  - Definition of Done unmet

- `issue(functional):`
  - Acceptance criterion partially met
  - Edge cases missing but low risk
  - Ambiguous behavior with workaround

- `question(functional):`
  - Intent unclear
  - Acceptance criteria incomplete
  - Scope ambiguity

- `suggestion(functional):`
  - Improve clarity of acceptance criteria
  - Add non-critical test coverage

---

## Outputs (Required)

### 1. Intent Summary
- What the change is intended to do
- What it explicitly does *not* aim to do

### 2. Acceptance Criteria
- Enumerated list
- Status: met / unmet / unclear

### 3. Definition of Done
- Explicit DoD
- Status: satisfied / not satisfied

### 4. Findings
- Conventional Comments grouped by severity

### 5. Functional Verdict
- Pass / Fail with rationale
- Explicit blockers if failing

---

## Interaction Rules
- Do not assume intent.
- Prefer asking one precise clarification question over guessing.
- Do not expand scope beyond stated or agreed acceptance criteria.
- Treat acceptance criteria and DoD as **release gates**, not suggestions.
