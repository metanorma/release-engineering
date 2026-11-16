# 5 — cli release, docker verification, close-out

## cli release (Tier 4)

HARD GATE: only after 4-local-samples-validation.md is green for EVERY
mn-samples-* repo. The owner gates this explicitly; an early dispatch has
already caused one screaming incident ("you cannot make a final cli release
UNTIL B is done").

```bash
gh workflow run release.yml --repo metanorma/metanorma-cli --ref main -f next_version=1.18.4
```

Then verify on rubygems (`gem list -r "^metanorma-cli$"`). Note: releasing cli
means its floors FREEZE the flavor versions — which is why the flavors must
all be released first (Tier 2) and the samples render must pass on exactly
that constellation (Tier 3, cli from git main).

### GitHub Releases verify + backfill (REQUIRED — has already failed silently)

The cli release flow pushes the git tag and publishes the gem but does NOT
create the GitHub Release object. The Releases page then shows an old version
as "Latest" and downstream users reasonably read that as "not released" — this
happened across the whole 1.18.x line (rubygems carried 1.18.1-1.18.6 while
the page showed "Latest: v1.17.0" for months, until TRThurman asked).

```bash
gh release list -R metanorma/metanorma-cli --limit 5
gh release view vX.Y.Z -R metanorma/metanorma-cli --json isLatest
```

If missing, create from the existing tag:

```bash
gh release create vX.Y.Z -R metanorma/metanorma-cli --latest \
  --title "metanorma-cli X.Y.Z" --notes-file notes.md
```

Backfilling several versions: create oldest-first, `--latest` ONLY on the
newest, `--latest=false` on the rest — the last-created release otherwise
becomes "Latest" regardless of version.

### metanorma/versions lockfile manifest

The metanorma/versions repository holds the resolved Gemfile.lock of every
released Docker container (consumed by actions-mn/setup). Publish the new
container's lockfile there, keyed by image version. A container released
without its metanorma/versions entry is invisible to setup-based consumers.

## docker verification (Tier 5)

metanorma-docker auto-triggers on the new cli release. Owner rule: "once cli
is released, you need to verify that docker builds succeed (auto-triggered)".

```bash
gh run list --repo metanorma/metanorma-docker --limit 3 --json databaseId,workflowName,status,conclusion,createdAt
gh run watch <run-id> --repo metanorma/metanorma-docker --exit-status
```

Verify the new image tag appears (registry) and the run conclusion is success.
If the auto-trigger does not fire within ~15 minutes of the rubygems publish,
dispatch the docker build workflow manually and say so in the report.

### docker deep verification (fresh digest is NOT fresh content)

1. **Publish-log gem check**: grep the Build+publish job log for
   `Installing <gem> <expected-version>` for every bundled gem. Reruns rebuild
   from the tag's frozen tree — a green matrix and a fresh digest can coexist
   with stale gems if the lock predates the wave.
2. **Float guard**: the relock resolves parser-layer gems (yeptris,
   lutaml-model, parsanol) fresh. A parser regression ships as a matrix
   failure — yeptris 0.6.66.0 corrupted YAML parsing under Ruby 4.0 and broke
   png_conform's diagnostics catalog in 20 of 26 jobs (2026-11-14). Pin the
   lock back to the last good version and file upstream; do not ship a
   known-bad float.
3. **Hub state**: `last_updated` moved and the digest changed. If the Hub did
   not update but the run says success, the publish job was skipped (check the
   job list, not just the run conclusion).

## close-out (Tier 6)

1. Close metanorma-iho#563 (the fontist→cli→docker chain ticket) with the
   release links.
2. Report back to petervwyatt on metanorma-pdfa: the shipped fixes
   (#102 standoc#1343 link-break fix, #109/#87 closed fixed-in-mn2pdf,
   #90 routed via mn2pdf#464 to Intelligent2013, #105 verified), the release
   versions carrying them, and the ISO verification results.
3. **Announce at metanorma/discussions**: post the release announcement in
   the metanorma/discussions repository (the fleet's announcements forum —
   Discussions are disabled on the individual gem repos). Include the
   version, the bundled gem-wave highlights, the Docker image tag, and links
   to the GitHub Release and the blog post.
4. **metanorma.org blog post**: add
   `_posts/YYYY-MM-DD-metanorma-cli-X.Y.Z-release.adoc` to metanorma.org (see
   the 1.11.3 post for the front-matter template) and PR it so the site
   rebuild carries it. The blog last covered 1.11.3; the step was skipped for
   the whole 1.16/1.17/1.18 series — resume it.
5. **Reporter per-issue confirmations**: every reporter-facing ticket fixed
   in the wave gets its own comment with the release version carrying the fix
   and the verification evidence, then closes. Independent issues stay
   independent (one fix per issue, one issue per defect).
6. Update memory (consolidation-state) with final versions + dates.
7. Final report to the owner: what shipped, what is left open, owners of
   open items.

## packed / tebako (external lane, track it)

The packed single-binary line (packed-mn via tebako) tracks the cli release
but is built by the tebako team. After the cli release: confirm the
packed-mn build was dispatched (or hand the tebako team the release pointer),
and record its completion state in the close-out report. Do not dispatch
tebako builds yourself unless the owner says so.
