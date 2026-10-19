# Harness provenance and design

Adapted from the [WalkingLab quick start](https://github.com/walkinglabs/learn-harness-engineering#quick-start-improve-your-agent-today)
and `docs/en/resources/templates` at commit
`38ddcd2bf8d65271f668b94e7c875ca1d629d622` (MIT; license in
`third_party/walkinglabs-harness-LICENSE`).

The four core templates are AGENTS.md, init.sh, feature_list.json, and
claude-progress.md. We also use the session handoff, clean-state checklist, and
evaluator rubric. Android-specific scripts replace the example npm commands.

Instructions are a short index. Architecture and runnable checks live separately.
Feature status requires command evidence; a build cannot stand in for a device test.
The progress log records failures and the next action across sessions. init.sh
verifies the host baseline and optionally starts the emulator/app; it never silently
installs tools or changes feature status. Bootstrap is a separate explicit action.

No scheduler, autonomous loop, external agent skill installation, or cloud account
is needed for this starter harness. Future features remain in the ledger until
requested and verified. Runtime artifacts use ignored .artifacts/; concise evidence
and limitations remain in the tracked progress log.
