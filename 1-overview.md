# 1 — Overview: the metanorma release wave

This directory documents the full metanorma release-wave process as executed in
the 2026-11-06 campaign. A future agent should be able to learn and re-run the
whole wave from these files alone.

## The dependency graph (release bottom-up, ALWAYS)

```
TIER 0  external gems        relaton (THEIR team) · glossarist (THEIR team)
                             fontist (THEIR team) — never release these yourself
TIER 1  leaf libs            mn-requirements · metanorma-release ·
                             metanorma-plugin-datastruct · metanorma-plugin-glossarist ·
                             stepmod-utils · metanorma-document ·
                             isodoc · metanorma-standoc · metanorma (core shell)
TIER 2  flavors              metanorma-{iso,iec,itu,ieee,iho,ogc,bipm,cc,ribose,gb,
                             jis,un,m3aawg,generic,ietf,oiml,plateau,taste}
                             (nist + bsi are PRIVATE: never on rubygems, never released)
TIER 3  local validation     ALL mn-samples-* repos render locally:
                             released gems + metanorma-cli from GIT MAIN
TIER 4  cli                  metanorma-cli release — GATED ON TIER 3 GREEN
TIER 5  docker               metanorma-docker auto-triggers on the cli release;
                             verify the build succeeds
TIER 6  registries + comms   GitHub Releases verify/backfill ·
                             metanorma/versions lockfile ·
                             announcement (metanorma/discussions) ·
                             metanorma.org blog post · packed/tebako
                             tracking · iho#563 closure, docs, final
                             report, AND report the shipped fixes back
                             to petervwyatt (metanorma-pdfa reporter)
```

**Why bottom-up:** cli's gemspec floors name released versions of every layer
below it. Releasing cli before the layers below means its floors resolve stale
gems. The 2026-11-06 owner correction: "iho is a dependency of cli, you must
release ALL metanorma-{flavor} gems before cli!!"

## Golden rules (violating ANY of these has already caused incidents)

1. **No prerelease gems in the stack.** Every dependency floor is a real
   released `~> X.Y.Z`. `.pre.alpha` floors/caps caused the fleet-wide bundler
   exit-6 solver failures (glossarist 2.14.12's `relaton ~> 3.0.0.pre.alpha`
   cap; cli main's `.pre` wall).
2. **Relaton floors are `~> 3.1.1`.** 3.1.0 lacks `lib/relaton/render.rb` (the
   facade entry); 3.1.1 ships both entries (`relaton/render` facade +
   `relaton-render` umbrella shim) — verified by gem contents. Both require
   forms are valid; do not crusade about require forms.
3. **No relaton-cli / relaton-render / relaton-bib dependencies anywhere** —
   not in gemspecs, not in Gemfiles, not in samples repos. The single `relaton`
   gem is the whole line.
4. **Version numbers are the owner's.** Patch bumps only; `version.rb` must
   sit BEHIND the `next_version` you dispatch; never invent a minor/major.
   Dispatch ONLY the repo's own `release.yml` (GHA), never a manual
   `gem push`.
5. **cli releases ONLY after ALL mn-samples-* repos render locally**
   (released gems + cli git main). No exceptions.
6. **Never release relaton, glossarist, or fontist** — those teams own their
   gems. File nothing there; watch their releases instead.
7. **No AI attribution** in commits, PRs, or releases — ever.
8. **mn2pdf is Intelligent2013's realm** — never touch mn2pdf code; file
   routing issues instead.
9. Merge by rebase; keep the merge allowlist to chain-relevant PRs; the owner
   may authorize direct `--admin` merges mid-wave.
10. **A release is not shipped until the registries and communications
    reflect it**: rubygems has the gem, the GitHub Release exists with the
    correct Latest marker, metanorma/versions holds the container lockfile,
    and the metanorma/discussions + metanorma.org announcements are posted.
    The GitHub-Releases gap (1.18.x invisible for months) and the blog gap
    (silent since 1.11.3) are the standing examples.

## The pipeline: stability → local testing → mn-samples wave → release → distribution

A maintainer judges one or more gem faces "stable" and wants them released and
distributed. The pipeline below is the whole path; every step links to the file
that details it. Partial waves are normal: release ONLY the faces the
maintainer named (their whole dependency subtree comes with them — use the
tier graph above), not the fleet.

```
 ┌────────────────┐  maintainer names the stable face(s)
 │ 0. STABILITY   │  version.rb still BEHIND the target; floors state real needs
 └───────┬────────┘
         ▼
 ┌────────────────┐  local renders on YOUR machine first (fast, stops the fleet)
 │ 1. LOCAL TEST  │  → 4-local-samples-validation.md (single-repo recipe)
 └───────┬────────┘
         ▼
 ┌──────────────────────┐  the SAME corpus set on the RELEASED gem candidates
 │ 2. mn-samples WAVE   │  (cli from git main) → 4-local-samples-validation.md
 └───────┬──────────────┘
         ▼
 ┌──────────────────────┐  tier dispatch, bottom-up: leaf libs → flavors → cli
 │ 3. RELEASE WAVES     │  (cli ONLY on Tier-3 green) → 3-release-wave.md
 └───────┬──────────────┘
         ▼
 ┌──────────────────────┐  docker auto-build → publish-log verify → Hub digest
 │ 4. DISTRIBUTION      │  metanorma/versions lockfile → GitHub Releases →
 │    + COMMUNICATIONS  │  metanorma/discussions announcement → blog post
 └───────┬──────────────┘  → 5-cli-docker-close-out.md
         ▼
 ┌──────────────────────┐  packed/tebako (external team) tracking; reporter
 │ 5. CLOSE-OUT         │  per-issue confirmations; final report → 5 + 6
 └──────────────────────┘
```

Steps 1-2 exist so that "stable" is a MEASURED judgment, not a feeling: the
local render is the fast loop (minutes, one repo, stops a bad cut before it
burns fleet CI), and the mn-samples wave is the same corpus set rendered on
exactly the release candidates (released gems + cli from git main) so the cli
floors are validated against the constellation that will actually ship. Skip
neither: both incidents on record started with a wave dispatched straight from
a green PR CI.

## The wave in one paragraph

Merge the PR wave (tier by tier, specs green or owner-ordered) → dispatch
Tier-1 lib releases in parallel → verify on rubygems → dispatch Tier-2 flavor
releases in parallel → verify → run the Tier-3 local samples validation →
only then dispatch the cli release → verify the docker auto-build → close out
iho#563 and the issue trackers.
