---
name: release-fleet
description: Act 1 of the staged release program — release the metanorma gem fleet (tier-1 leaf libs and tier-2 flavors) and run the tier-3 local samples validation, but HOLD the cli gate. The cli ships later as a user-testable prerelease (/release-prerelease) and then goes live. Use when the owner asks to release everything except the cli gate, stage the fleet, or hold the final release.
argument-hint: [tracker-location]
disable-model-invocation: true
---

Execute Act 1 of the staged program: release the fleet, hold the cli gate.

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
     main-ahead delta the coming prerelease will carry, and the
     handoff — the cli ships next as a USER-TESTABLE prerelease
     (Act 2, `/release-prerelease`), whose gemspec locks the necessary,
     minimal underlying gems against what this wave released.
   - Tier 5 (docker) and Tier 6 communications (announcement, blog,
     metanorma/versions) do NOT run.

Completion of this mode = Tiers 1-3 verified, GitHub Releases verified
for every repo released in Tiers 1-2, and the tracker showing T1-T3
done with T4-T6 explicitly marked HELD (awaiting the prerelease act).

The wave tracker stays OPEN — Act 2 (`/release-prerelease`) puts the
user-testable cli prerelease out with a call for testing, and Act 3
(`/release <final>`) closes the tracker: its ledger + changelog diff
spans this entire staged wave in one step against the last docker tag,
and its announcement goes to metanorma/discussions.

STOP-AND-ASK gates from the `release` skill apply unchanged. Never name
the prerelease version; never touch cli's gemspec in this act — the
minimal lock plan is derived and approved in Act 2.
