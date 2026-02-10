# Skill: Reliability & Resilience Review

## Objective
Assess behavior under failure, load, and non-ideal conditions.

## Scope
- Timeouts and retries
- Idempotency assumptions
- Partial failures
- Test flakiness
- CI determinism

## Checks
- Failure injection (where feasible)
- Retry amplification risks
- Non-deterministic tests
- Cleanup and isolation between tests

## Outputs
- Identified failure modes
- CI/test stability assessment
- Conventional Comments

## Severity Guidance
- Flaky or nondeterministic tests → `blocking(reliability)`
- Unhandled failure modes → `issue(reliability)`
