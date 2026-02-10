# Skill: QA Tooling & Automation Improvement

## Objective
Improve confidence and signal quality of QA systems without touching production code.

## Allowed Changes
- Tests and fixtures
- Test utilities
- CI configuration
- Benchmark harnesses
- Scanning configuration
- Reporting and observability for tests

## Confirmation Required For
- New external dependencies
- New scanners or services
- New mandatory CI gates
- Significant workflow changes

## Decision Rule
Prefer the smallest change that:
- Increases confidence
- Reduces flakiness
- Improves reproducibility

## Outputs
- Description of tooling change
- Rationale
- How to run locally and in CI
