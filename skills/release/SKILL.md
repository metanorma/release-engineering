---
name: release
description: Run a full validated metanorma release wave (tiers 1-6, leaf gems through docker through registries and communications). Use ONLY when the owner explicitly orders a release wave with a target version. Not for single-repo gates, verification of an already-shipped release, or dry runs.
argument-hint: <cli-version> [tracker-location]
disable-model-invocation: true
---

Execute the metanorma release wave exactly as documented in this plugin.

1. Read, in order: `${CLAUDE_PLUGIN_ROOT}/README.md`,
   `${CLAUDE_PLUGIN_ROOT}/1-overview.md` through
   `${CLAUDE_PLUGIN_ROOT}/6-troubleshooting.md`.
2. Execute the fenced prompt in
   `${CLAUDE_PLUGIN_ROOT}/7-release-prompt.md` with the target version
   from the arguments. Where the docs and observed reality conflict,
   stop and ask — never improvise around a gate.

Authorization gates (STOP-AND-ASK, always):
- The version number is the owner's decision. Patch = version.rb + 1 is
  fine for a routine wave; ANY other bump waits for the owner's explicit
  number, even if the mechanics look identical.
- Irreversible actions (docker tag deletion for the refresh flow,
  force-pushes, dependency floors) need explicit owner go-ahead.
- Gems owned by other orgs (relaton, fontist, glossarist, pubid,
  tebako slices) are never released by this flow — request via issues
  in their repos.

Wave tracker: open it at step 0 from
`${CLAUDE_PLUGIN_ROOT}/wave-tracker-template.md` in the location given
in the arguments (default: metanorma/discussions), and keep the mermaid
stage classes and checkboxes in sync at every gate.

Close-out tier 6: run `${CLAUDE_PLUGIN_ROOT}/gem-ledger.rb` and
`${CLAUDE_PLUGIN_ROOT}/gem-changelog.rb` (see the `wave-report` skill
for the exact posting recipe) and finish with the FULL PROPER REPORT —
a wave without the report, the ledger, and the changelog is not done.
