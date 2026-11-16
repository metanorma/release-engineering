# 7 — The release prompt (paste-ready for the next validated release)

Run the wave from a clean clone-per-repo posture. This prompt assumes
`~/src/mn/release-process/{1-6}.md` are read first.

```
GOAL: run a fully-validated metanorma release wave, tiers 1-6, bottom-up.

STATE CHECK (do first): `gem list -r` the current latest of every tier-1/2
gem; read each repo's version.rb; confirm the release workflows exist
(.github/workflows/release.yml). Anything already released = skip; anything
with main-ahead fixes = include.

RULES (violating any = incident):
- Dependency floors: real released `~>` only; relaton `~> 3.1.1`; ZERO
  relaton-cli/relaton-render/relaton-bib/asciichem anywhere; no `.pre`
  floors; no exact pins (canon/pubid/moxml/lutaml-model exact holds rot).
- ZERO git-main pins in Gemfiles where a released equivalent exists
  (mn-samples repos keep exactly ONE: metanorma-cli @ git main).
- Releases ONLY via each repo's release.yml, next_version = version.rb +
  patch. Never invent versions. rubygems versions are forever.
- Never release relaton/glossarist/fontist/tebako-slices (their teams);
  request via gh issues in their repos (tebako-packages IS ours — file
  issues there).
- Instant-PR pattern: create → `gh pr merge <NUM> --repo <r> --rebase
  --admin` → cancel that branch's runs → verify remote state explicitly
  (piped && chains hide failed pushes). Cancel useless non-release CI
  fleet-wide to unblock the runner queue.
- cli releases ONLY after ALL mn-samples-* render LOCALLY on released gems
  + cli git main (gb excluded by ruling). Local = this machine, not GHA.
  Verify each repo: bundle → forbidden-grep == 0 → config-selected render.
- No AI attribution anywhere. mn2pdf is Intelligent2013's realm.

TIERS:
1. Tier-1 libs (parallel): mn-requirements, metanorma-release,
   plugin-datastruct, plugin-glossarist, stepmod-utils, metanorma-document,
   isodoc, metanorma-standoc, metanorma. Verify each on rubygems before T2.
2. Tier-2 flavors (parallel, after T1): all 18 metanorma-{flavor} gems,
   patch bumps from their own version.rb. Verify each on rubygems.
3. Tier-3 LOCAL gate (MANDATORY repos, all of them): the full mn-samples-*
   roster EXPLICITLY INCLUDING **plateau, plateau-cg3, and expressdocs**
   (plus iso, iec, iec-private, ieee-private, iho, itu, ieee, bipm, cc,
   ribose, jis, un, m3aawg, generic, ietf, oiml, jcgm, bsi, nist, iala,
   icc, mbxif, pdfa; gb excluded by ruling; swf broken upstream).
   Released gems + cli git main; per repo: bundle → forbidden-grep 0 →
   config-selected render → log PASS/FAIL with html count. Pre-existing
   reds (check the repo's OWN CI history before blaming the wave): jis
   doc-format, swf (broken upstream), nist (credential-gated). Fix
   failures at SOURCE; re-run.
4. cli release (only if T3 fully green) → verify on rubygems.
5. docker: release-tag.yml (next_version=<cli>) → tag → build-push →
   ALL per-flavor smokes green; tebako: check tpkg-registry.yaml has the
   payload (tebako-packages#issue if not) → sync-payload.rb → build.
6. Registries + communications (a release is NOT done without these):
   a. GitHub Releases: `gh release list` on EVERY released repo must show
      the new tag with the correct Latest marker; if the release flow
      pushed the tag without creating the Release object, backfill
      (`gh release create vX.Y.Z --latest --notes-file ...`; backfill
      oldest-first, `--latest` ONLY on the newest).
   b. metanorma/versions: the released Docker container's Gemfile.lock is
      published there (actions-mn/setup consumes it).
   c. Announcement at metanorma/discussions (the fleet announcements
      repo — Discussions are disabled on individual gem repos).
   d. metanorma.org blog post: _posts/YYYY-MM-DD-metanorma-cli-X.Y.Z-release.adoc.
7. Close-out: downstream issue posts (per-issue, independent), reporter
   per-issue confirmations with release pointers + verification evidence,
   release-process docs + memory update, final report with every version
   and every PR.

FULL PROPER REPORT (mandatory Tier-6 deliverable, posted where the
reporter/consumers can see it):
- Per-repo validation table: repo | bundle | forbidden-grep | render
  PASS/FAIL | html count | stack versions used.
- Per-DOCUMENT validation-message catalogs, KEPT SEPARATE PER DOCUMENT
  (never merged across documents): every distinct validation/style/error
  message emitted by that document's compile on the released stack, so
  the reporter can verify each document independently.
- PDF output confirmation per document: exit code, file size,
  `pdfinfo` check (Tagged/Producer/Pages).
- Container confirmation: the published image tag + the CI per-flavor
  smoke results; a local `docker run` compile of at least one document.
- The full version ledger (every gem, every release) and the PR list.

Do not stop until all six tiers are verified complete.
```
