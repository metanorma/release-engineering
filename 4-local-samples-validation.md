# 4 — Local samples validation (THE cli release gate)

Owner rule: "cli can only be released ONCE all mn-samples-* repos work
LOCALLY." "Locally" means on this machine, NOT on GitHub Actions. metanorma-cli
comes from GIT MAIN; every other gem must be a RELEASED version.

## The contract per mn-samples repo

1. Fresh clone (depth 1 is fine).
2. Gemfile contract:
   - `gem "metanorma-cli", github: "metanorma/metanorma-cli", branch: "main"`
   - every other gem at its RELEASED version (`~>` floors); NO git pins for
     anything else; NO relaton-cli / relaton-render / relaton-bib lines.
3. `rm -f Gemfile.lock && bundle install`
4. **Forbidden-gem grep** — must be ZERO:
   ```bash
   grep -E "^    (relaton-render|relaton-cli|relaton-bib|asciichem|metanorma-plugin-asciichem) \(" Gemfile.lock
   ```
5. Render ONLY what the repo's config selects — each mn-samples repo carries
   `metanorma.yml` / `metanorma.test.yml` listing the documents under test;
   do NOT render everything (e.g. mn-samples-oiml's full set takes far too
   long — test the config-selected few). The repo's rake task already honors
   the config.
6. Spot-check outputs exist and are non-empty (XML + HTML).

## No duplicate validation (owner rule)

If GHA has ALREADY passed a sample repo's build on the same constellation, do
NOT repeat it locally. If we validate locally, CANCEL the equivalent GHA run —
local is ~4x faster and GHA runs contend with everyone else's queues. Pick one
lane per repo per change; never both.

## Execution: parallel agents, plain local runs

Owner ruling 2026-11-06: "you don't need to use docker locally, just use an
agent to run locally." Spawn parallel agents, each owning a batch of repos and
executing the per-repo contract above directly on this machine (plain
`bundle install` + `bundle exec rake`); no docker/drun/memrun orchestration
needed for this validation. Each agent writes a per-repo result line
(bundle / forbidden-grep / render / artifacts) and reports failures with logs.

## Runtime notes

- Fonts: flavor samples need fontist fonts; expect the first render to fetch.
- Expect 3–10 minutes per repo (bundle + render); ~25 repos total.
- Keep a per-repo result table: bundle / forbidden-grep / render / artifacts.

## What clean means

A repo passes when: bundle resolves on released gems + cli main, the lock
grep is zero, every document renders without a render-stack crash (the
`NameError: uninitialized constant Relaton::Render::Unrenderable` class of
failure was the old mixed relaton-render bundle), and the outputs are
well-formed. Style/validation warnings are NOT failures.

Any failure: capture the log, root-cause against the wave (was a Tier-1/2
release missed? a stale pin somewhere?), fix at the SOURCE, and re-run.

## Repo roster (2026-11-07)

Tier-3 roster (public + private): iso, iec, iec-private, ieee-private, iho, itu, ieee, bipm, cc, ribose, gb (EXCLUDED by owner ruling), jis, un, m3aawg, generic, ietf, oiml, plateau, plateau-cg3, jcgm, bsi, nist, iala, icc, mbxif, swf (broken upstream), pdfa, **expressdocs** (metanorma/mn-samples-expressdocs — wg12/EXPRESS synthetic corpus; auto-included in the docker smoke matrix via build-sample-matrix.yml; validated 2026-11-07: 52 HTML, forbidden-grep 0, latest released stack + cli git main).

## MANDATORY named repos (owner directive 2026-11-07)

plateau and plateau-cg3 are NOT optional Tier-3 targets — they are explicitly
required by name in every wave. expressdocs likewise (metanorma/mn-samples-expressdocs,
the wg12/EXPRESS synthetic corpus; auto-included in the docker smoke matrix
via build-sample-matrix.yml, and in the cli sample legs via cli's
samples-smoke-matrix.json).

## The report (owner directive 2026-11-07)

A release is not done until a FULL PROPER REPORT exists:
1. Per-repo validation table (repo | bundle | forbidden-grep | render |
   html count | stack versions).
2. Per-DOCUMENT validation-message catalogs — SEPARATE PER DOCUMENT,
   never merged across documents — listing every distinct message the
   document's compile emitted on the released stack (reporter-facing:
   he verifies each document against its own list).
3. Per-document PDF confirmation: exit code, size, pdfinfo (Tagged/
   Producer/Pages).
4. Container confirmation: published tag + CI smoke results + one local
   `docker run` compile (note any local disk/daemon limitation honestly).
5. Full version ledger + PR list.
