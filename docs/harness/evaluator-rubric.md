# Evaluator rubric

Adapted from the WalkingLab starter template. Apply after each feature.

| Category | Acceptance question |
| --- | --- |
| Correctness | Does behavior match the selected feature's acceptance criteria? |
| Verification | Did required checks actually run with evidence? |
| Scope | Did work stay within the requested feature or necessary supporting fixes? |
| Reliability | Does the standard startup work again without manual repair? |
| Maintainability | Can the next agent understand the architecture and commands? |
| Handoff | Are state, limitations, and next steps recorded on disk? |

Verdict: accept only when all applicable questions pass. Otherwise revise or record
a blocker. A reviewer must report missing evidence and the next review trigger.

## Foundation review — October 18, 2026

- Correctness: create, edit, explicit save, list, and reopen implemented.
- Verification: four ViewModel tests; Room disk close/reopen test; Compose journey;
  force-stop/relaunch smoke. Commands and outcomes in claude-progress.md.
- Scope: no backend, autosave, search, delete, or release service was introduced.
- Reliability: pinned wrapper/toolchain; explicit bootstrap; rerunnable startup.
- Maintainability: one module, repository boundary, injected test dependencies,
  version catalog, committed schema, and scripts shared with CI.
- Handoff: feature ledger distinguishes passing and future/unverified work.

Verdict: accept the local development foundation. This is a self-review, not an
independent agent review. Remote CI, managed API 35, minimum API 28, tablet, real
hardware, OS process-death recovery, and production release behavior are unverified.
These limitations do not count as passing coverage. Next review: autosave design.
