---
name: release-smoke
description: Zero-side-effect dry run of the metanorma release flow — proves every gate and report without dispatching anything. Use when asked to rehearse, dry-run, smoke-test, or validate the release process itself.
argument-hint: [hypothetical-version]
---

Execute the smoke test exactly as documented in this plugin.

1. Read, in order: `${CLAUDE_PLUGIN_ROOT}/README.md`,
   `${CLAUDE_PLUGIN_ROOT}/1-overview.md` through
   `${CLAUDE_PLUGIN_ROOT}/6-troubleshooting.md`.
2. Execute the fenced prompt in
   `${CLAUDE_PLUGIN_ROOT}/8-smoke-test-prompt.md` verbatim, with
   the hypothetical target version from the arguments (default 1.18.7).

The HARD RULES inside that prompt are absolute: the only permitted
shared-state writes are the smoke tracker issue and process-gap issues
in metanorma/release-process itself. No releases, no tags, no docker,
no public communications, no reporter-issue activity of any kind.

The deliverable is the closing verdict: would this flow have produced a
correct, complete, verifiable release? File one issue per documentation
gap encountered, and answer the verdict straight.
