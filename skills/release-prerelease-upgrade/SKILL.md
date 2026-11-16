---
name: release-prerelease-upgrade
description: Upgrade an existing metanorma-cli prerelease line to the fleet's new floors — underlying gems released new minors after the cut, so the prerelease's minimal gemspec locks re-derive, the affected gates re-run, and a new dated prerelease cuts. Use when the fleet moved after /release-prerelease and the prerelease must catch up. Not for the first cut (/release-prerelease) or the live release.
disable-model-invocation: true
---

Execute Prompt B of `${CLAUDE_PLUGIN_ROOT}/9-prerelease-prompt.md`
verbatim (read docs 1-6 and `3-release-wave.md` § Staged release
program first). The two decisions that make this different from a
fresh cut:

- **No floor movement, no re-cut**: if every gem in the current lock
  plan moved only within patches, STOP and say so — the `~>` locks
  already float across patches, and a version number must never be
  spent on a no-op.
- **Conflicts resolve upward, never sideways**: a fleet gem raising its
  own floors bumps the REQUIRING gem's locked minor in the plan.
  Loosening to exact pins or dropping gems from the lock set is not a
  resolution.

Every cut is a new dated prerelease; the existing call-for-testing
thread is updated in place, never duplicated; the tracker stays open
and gains one line of prerelease iteration history.
