# 9 — Pre-release prompts (Act 2 of the staged program)

Two paste-ready prompts. **Prompt A** cuts the next pre-release (first
cut or a normal iteration). **Prompt B** upgrades an existing
pre-release line to the fleet's new floors — use it when underlying gems
released new minors after the cut and the prerelease must catch up.
Both assume docs 1-6 and `3-release-wave.md` § Staged release program
are read first, and both enforce the same standing rules as
`7-release-prompt.md`.

## Prompt A — make the next pre-release

```
MAKE THE NEXT METANORMA-CLI PRE-RELEASE (Act 2 of the staged program)

Clone https://github.com/metanorma/release-engineering anywhere (skip if you
already hold a checkout); `<RELEASE-PROCESS>` below is its path. Read
`<RELEASE-PROCESS>/README.md`, docs 1-6, and
3-release-wave.md § "Staged release program". Then execute Act 2
exactly.

PRE-VERSION: <x>.<y>.<z>.pre.<yyyymmdd> — stated by the owner. Refuse
to invent, guess, or "bump" it; iterations go by date.

SEQUENCE:
0. Preconditions: Act 1 completed — fleet gems released, tier-3 local
   samples gate green, tracker open with T4-T6 marked HELD. If not,
   STOP and say what is missing.
1. Derive the minimal gemspec lock plan: metanorma-cli's DIRECT runtime
   dependencies only (the gemspec add_dependency lines / the flavor
   registry cli actually loads), each at `~>` of the MINOR the tier-3
   gate validated. Never exact pins (fleet rule), never transitive or
   dev dependencies, never flavor gems cli does not load. POST THE PLAN
   and WAIT for owner approval.
2. Apply the approved locks (PR, instant-merge per the prompt rules),
   release cli <pre-version> via release.yml, and verify the exact
   version is fetchable from rubygems.
3. Build and push the prerelease docker image (default tag: the version
   string), run ALL per-flavor smokes on it, record the evidence on the
   tracker.
4. Create the cli GitHub Release for <pre-version> marked PRE-RELEASE —
   never the Latest marker.
5. Draft the CALL FOR TESTING for metanorma/discussions: install lines
   (gem + docker), what changed, the feedback channel. SHOW THE OWNER
   THE DRAFT and post only after approval. This is an invitation, NOT
   the release announcement.
6. Tracker: record the prerelease state and the feedback window; T4
   annotated as pre-release cut, T5/T6 remain HELD. The tracker stays
   open — Act 3 (/release <final>) closes it.

RULES: every standing rule of 7-release-prompt.md applies (Ruby 4.0
docker, no other-org releases, evidence before reporting, --body-file
posting, no AI attribution). rubygems never re-admits a version: a
botched cut iterates to the NEXT DATE, never a re-push.
```

## Prompt B — upgrade the pre-release to the new floors

```
UPGRADE THE METANORMA-CLI PRE-RELEASE TO THE NEW FLOORS OF THE
UNDERLYING GEMS

Use when the fleet released new versions AFTER the current prerelease
was cut and the prerelease line must catch up. Read the same docs as
Prompt A first.

0. Find the existing prerelease line: current prerelease version, its
   gemspec lock plan, its docker tag, its call-for-testing thread.
1. MOVEMENT INVENTORY: for every gem in the current lock plan, compare
   the released version at cut time with the latest released now
   (`gem list -r` / rubygems API). Classify each: unchanged | new patch
   (same minor) | new minor (floor moved). If nothing moved beyond
   patches, STOP and report "no floor movement; no re-cut needed" —
   the `~>` constraints already float across patches.
2. RE-DERIVE the lock plan: each moved minor locks at `~>` of the NEW
   minor; the set stays MINIMAL (direct runtime dependencies only).
   Fresh-resolve the new combination (clean bundle with the planned
   constraints). Conflicts (e.g. a fleet gem raised its own floors) are
   reported and resolved by bumping the REQUIRING gem's locked minor —
   never by loosening to exact pins or dropping gems.
3. RE-GATE: run the tier-3 local samples gate on the new combination —
   the repos the moved gems feed at minimum; the FULL roster when a
   tier-1 lib moved. Red = fix forward, not release.
4. Owner approval: present the re-derived lock plan + gate evidence;
   WAIT.
5. Cut: new dated prerelease <x>.<y>.<z>.pre.<TODAY> (owner-stated or
   confirmed; never reuse or re-push a version), apply locks, release
   via release.yml, rebuild and re-smoke the docker pre image, create
   the new GitHub PRE-release.
6. UPDATE the existing call-for-testing thread in place (same thread:
   new version, new docker tag, what moved). Never open a parallel
   thread. Append the iteration to the tracker's prerelease history;
   the tracker stays open.
```
