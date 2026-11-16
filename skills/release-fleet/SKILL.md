---
name: release-fleet
description: Release the metanorma gem fleet — tier-1 leaf libs and tier-2 flavors — and run the tier-3 local samples validation, but HOLD the cli/docker/tebako/communications gates for the separate final cli release, which will be a pre-alpha version whose gemspec locks the necessary minimal underlying gems. Use when the owner asks to release everything except the cli gate, stage the fleet, or hold the final release.
argument-hint: [tracker-location]
disable-model-invocation: true
---

Execute a STAGED wave: release the fleet, hold the cli gate.

1. Read, in order: `${CLAUDE_PLUGIN_ROOT}/README.md`,
   `${CLAUDE_PLUGIN_ROOT}/1-overview.md` through
   `${CLAUDE_PLUGIN_ROOT}/6-troubleshooting.md`.
2. Execute the fenced prompt in
   `${CLAUDE_PLUGIN_ROOT}/7-release-prompt.md` for **Tiers 1-3 only**,
   with the deltas in
   `${CLAUDE_PLUGIN_ROOT}/3-release-wave.md` § "Staged waves (hold the
   cli gate)":
   - Tiers 1-2 (libs, flavors): run exactly as written — real releases,
     rubygems verification per gem.
   - Tier 3: run exactly as written — the full local samples gate on
     released gems + cli git main.
   - Tier 4 (cli) HELD: no cli release, no version choice, no gemspec
     edit. Record on the tracker: cli's current version.rb, the
     main-ahead delta the final release will carry, and the handoff
     note — the final cli release is a PRE-ALPHA whose gemspec locks
     the necessary, minimal underlying gems against what this wave
     released.
   - Tier 5 (docker) and Tier 6 communications (announcement, blog,
     metanorma/versions) do NOT run.

Completion of this mode = Tiers 1-3 verified, GitHub Releases verified
for every repo released in Tiers 1-2, and the tracker showing T1-T3
done with T4-T6 explicitly marked HELD (awaiting final cli pre-alpha).

The wave tracker stays OPEN — the final cli/docker/tebako release wave
closes it: its ledger + changelog diff spans this entire staged wave in
one step against the last docker tag, and its announcement goes to
metanorma/discussions.

STOP-AND-ASK gates from the `release` skill apply unchanged. Never name
the pre-alpha version; never touch cli's gemspec in this mode — the
minimal lock plan is decided at the final release, by the owner.
