---
name: wave-report
description: Generate and post the wave tracker's two standing comments — the all-gems version ledger (diffed against the previous wave) and the per-gem changelog plus wave summary. Use at wave close-out or when asked to produce or post a release ledger or changelog.
argument-hint: v<prev> v<wave> [tracker-issue-or-discussion-url]
---

Produce and post the wave tracker's standing report comments.

1. Read `${CLAUDE_PLUGIN_ROOT}/wave-tracker-template.md` (the ledger and
   changelog sections) and `${CLAUDE_PLUGIN_ROOT}/GEM-OWNERSHIP.md`
   (the scripts' manifest — do not regenerate it).
2. Run `${CLAUDE_PLUGIN_ROOT}/gem-ledger.rb v<prev> v<wave>` — post its
   output verbatim as one comment. The output is changed-first: the
   "Changed in this wave" table on top, unchanged gems collapsed behind
   a `<details>` dropdown; do not flatten or re-sort it.
3. Run `${CLAUDE_PLUGIN_ROOT}/gem-changelog.rb v<prev> v<wave>` — write
   a one-paragraph wave narrative from the wave's actual work, prepend
   it above the mechanical summary, and post as the second comment.

Posting rules:
- `gh` with `--body-file` ALWAYS. Never inline comment bodies containing
  backticks — command substitution has leaked secrets that way.
- Never hand-edit tool output except adding the narrative above it.
  If a tool errors or omits a gem, fix the tool/report the gap — do not
  fake the row.

A gem shipped to rubygems without its git tag surfaces in the changelog
output as a release-hygiene gap: flag it on the tracker, then leave the
fix to the owning team unless the owner directs otherwise.

The ledger's **Manifest drift** section names gems to add to or prune
from `GEM-OWNERSHIP.md` (ownership changes: new gems appear, old gems
are removed). Apply every drift finding in this wave — update the
manifest in the same change that posts the report — or the next wave's
ledger silently misses them.

If a tracker URL was given, also sync its body (mermaid stage classes,
checkboxes) to reality — never check a box the oracle does not show.
