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
