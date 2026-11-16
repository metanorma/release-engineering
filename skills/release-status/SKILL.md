---
name: release-status
description: Read-only "where are we" report for the metanorma fleet — latest released versions versus main-ahead work per repo, last wave state, docker Hub state, and what the next wave would include. Use for release-readiness questions. Writes nothing anywhere.
---

Produce the release state report. This skill is strictly read-only: no
dispatches, no comments, no issue activity, no writes of any kind.

1. Run the STATE CHECK from
   `${CLAUDE_PLUGIN_ROOT}/7-release-prompt.md` standalone:
   - `gem list -r` across every tier-1 and tier-2 gem; each repo's
     version.rb; release.yml existence.
   - Main-ahead commits per repo (unreleased work the next wave would
     carry).
   - The last docker tag + its Hub digest and publish date.
2. Output: one compact table — repo | released | main-ahead |
   would-include — then a short prose summary naming the wave-blocking
   items (the lanes that must close before the next cli release) and
   the repos owned by other orgs that this fleet never releases.

Tier definitions and the "never release" list come from
`${CLAUDE_PLUGIN_ROOT}/GEM-OWNERSHIP.md` and docs 3 and 7.
