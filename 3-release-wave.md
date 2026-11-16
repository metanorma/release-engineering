# 3 — The release wave (dispatching and verifying)

## Preconditions per repo

1. The change PRs are MERGED to main.
2. Read `lib/**/version.rb` on main — the CURRENT version. The release target
   `next_version` = current version.rb with the PATCH incremented (never
   invent minors; never dispatch a version ≤ version.rb).
3. The repo has `.github/workflows/release.yml` (the thin wrapper that calls
   metanorma/ci's rubygems-release reusable).

## Dispatch (all repos in a tier in PARALLEL)

```bash
gh workflow run release.yml --repo metanorma/<repo> --ref main -f next_version=X.Y.Z
```

The workflow resolves `lib/**/version.rb`, bumps it in a commit, builds, and
publishes to rubygems. If it fails at the version check, re-read version.rb —
someone may have released ahead of you.

## Verify

Watch rubygems, not just the workflow:

```bash
gem list -r "^<gem>$"          # or the rubygems.org API for exact versions
```

A run can go green while the push silently fails; the published version is
the only truth. Tier 3 must NOT start until every Tier-2 flavor version is
actually fetchable.

## Tier assignments (2026-11-06 execution, reuse the shape)

- Tier 1 (libs): mn-requirements 0.5.15, metanorma-release 0.2.26,
  plugin-datastruct 0.3.13, plugin-glossarist 0.5.10, stepmod-utils 0.6.10,
  metanorma-document 0.5.5, isodoc 3.7.11, metanorma-standoc 3.5.10,
  metanorma 2.5.16
- Tier 2 (flavors): iso, iec, itu, ieee, iho, ogc, bipm, cc, ribose, gb, jis,
  un, m3aawg, generic, ietf, oiml, plateau, taste — patch-bump each from its
  own version.rb. nist/bsi are PRIVATE — never released.
- Tier 4: metanorma-cli 1.18.4 — ONLY after Tier 3 (local samples) is green.

## Known release-workflow traps

- Version-file resolution anchors on `lib/<gem>/version.rb` (metanorma/ci#476);
  nested/odd layouts must match.
- The bump commit stages `$VERSION_FILE` (ci#479); don't leave version.rb
  dirty before dispatching.
- Multi-gem monorepos need gem-name scoping (ci#471) — relaton is single-gem now.
- Cancel stray auto-dispatched releases immediately; rubygems never re-admits
  a version number, not even a yanked one.

## Staged release program (stage the fleet, pre-release testing, then live)

The wave runs as three acts so end users can compile THEIR documents on
the coming cli and report findings before the fleet goes live. The
governing practice is release channels: the pre-release is published and
opt-in — never a private build — and promotion, not re-release, moves it
to live.

### Act 1 — stage the fleet (`/release-fleet`)

Tiers 1-3 run exactly as written: fleet gems released, the local samples
gate green. The cli gate is HELD — no cli release, no gemspec edit.
Completion: tracker marks T4-T6 HELD; GitHub Releases verified for every
repo released in Tiers 1-2. The tracker stays open.

### Act 2 — pre-release for end-user testing (`/release-prerelease`)

Goal: end users test their documents on the coming cli through normal
channels and report findings while nothing is live.

- cli publishes to rubygems as a PRERELEASE, owner-stated version in the
  fleet's `.pre.` date form (`<x>.<y>.<z>.pre.<yyyymmdd>`; iterate by
  date; never guessed). Opt-in: `gem install metanorma-cli -v <V>` —
  rubygems serves prereleases only on explicit request, so live users
  are untouched.
- A docker image is built and pushed for the prerelease (default tag:
  the same version string), with the per-flavor smokes run on it, so
  users compile documents the way they normally do.
- The cli gemspec locks the NECESSARY but MINIMAL underlying gems:
  lock set = cli's direct runtime dependencies (the gemspec
  add_dependency lines / the flavor registry cli actually loads), each
  at `~>` of the minor version the Act-1 tier-3 gate validated. Never
  exact pins (fleet rule), never transitive or dev dependencies, never
  flavor gems cli does not load. The derived lock plan goes to the
  owner for approval before any gemspec commit.
- The cli GitHub Release for the prerelease is marked PRE-RELEASE.
- A CALL FOR TESTING goes to metanorma/discussions: exact install and
  docker-compile instructions, what changed, and the feedback channel.
  This is an invitation, NOT the release announcement. The draft goes
  to the owner before posting.
- Findings in the window fix forward: fleet fixes re-run the Act-1
  gates as needed; each iteration is a new dated prerelease. The
  tracker stays open throughout.

### Act 3 — live (`/release <final>`)

The owner states the final cli version. The Act-2 gemspec locks stand as
they are — they re-derive only if the fleet moved during the testing
window (in which case the affected tier-3 gates re-run first). Docker
final tags, metanorma/versions lockfile, tebako packed build, the GitHub
Release Latest marker, the real announcement in metanorma/discussions,
and the blog post follow the standard tiers 5-6. The wave tracker closes
with the ledger + changelog spanning the whole program in one diff
against the last docker tag.
