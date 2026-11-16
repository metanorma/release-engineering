# 6 — Troubleshooting: the traps already paid for

Every item below cost real time in the 2026-11-06 campaign. Read before
re-running the wave.

1. **relaton ≤ 3.1.0 lacks `lib/relaton/render.rb`.** In a relaton-only bundle
   `require "relaton/render"` LoadErrors, or silently binds to a still-bundled
   retired relaton-render 3.0.0 whose general.rb rescues an
   `Unrenderable` constant it never defines → `NameError: uninitialized
   constant Relaton::Render::Unrenderable` mid-render. Fix = floor
   `relaton ~> 3.1.1`, never edit requires fleet-wide. Verify gem contents
   (`gem fetch` + tar) before asserting packaging facts.
2. **Retired gems in the graph:** relaton-render 3.0.0 + relaton 3.x both ship
   `lib/relaton/render/` — $LOAD_PATH order decides which wins; the mixed load
   is the crash above. Trace the puller with the lockfile:
   `awk '/^GEM/{g=1} /^PLATFORMS/{g=0} g && /^    [a-z]/{gem=$1} g && /^      relaton/{print gem, $1}' Gemfile.lock`
3. **Prerelease caps break the solver** (bundler exit 6): read the
   "Could not find compatible versions" chain bottom-up; the last pair is the
   actionable conflict.
4. **relaton 3.1 floors `parsanol ~> 1.3.129`** — old exact holds
   (`parsanol = 1.3.114`, `< 1.3.120`) in Gemfile.devel files conflict with it.
5. **gb's `isodoc ~> 0.8.8`** was an impossible floor (isodoc is 3.7.x).
6. **`cmd | tail -1` inside `&&` chains masks failures** — the pipe returns
   tail's exit 0, so chains continue past broken steps and pushes silently
   don't land. Verify remote state explicitly after every push
   (`gh api repos/.../contents/<file>?ref=<branch>`).
7. **PR rollups mix stale SHAs** — a PR's statusCheckRollup can show failures
   from a pre-push run. Check the specific run ID for the current head SHA.
8. **`gh run list --limit 1` can grab the wrong workflow** (lint vs rake) —
   filter by `--workflow`.
9. **Merge monitors:** poll statusCheckRollup (0 pending + 0 failed) per the
   workflow-filter rule; `gh run rerun` replays snapshots — dispatch fresh
   runs after reusable-workflow merges.
10. **rubygems versions are forever** — a wrong next_version dispatch must be
    cancelled BEFORE publish; yanked versions can never be re-pushed.
11. **External-team gems (relaton, glossarist, fontist):** watch releases,
    never PR. A stray PR gets closed with an apology comment.
12. **No third-party filings** (asciidoctor etc.) — write-ups to the owner,
    fixes vendored on our side.

13. **Removing a plugin needs BOTH the require AND the registration.** standoc
    3.5.10 dropped the `metanorma-plugin-asciichem` require but kept the
    `Metanorma::Plugin::Asciichem` registration in converter.rb — caught only
    by the local sample render, not by unit specs. Grep registrations
    case-sensitively (`Asciichem`, not just `asciichem`) when retiring a plugin.
14. **Exact pins rot silently.** The wave tripped on `canon = 0.3.87`,
    `pubid = 2.0.0`, `moxml = 0.5.153`, `lutaml-model = 0.8.114` — all once-valid
    exact holds that block new floors. Prefer `~>` everywhere; audit exact pins
    before releasing a dependent gem.
15. **A frozen lockfile hides new releases.** `bundle install` with an existing
    lock keeps stale versions; after a wave, `rm Gemfile.lock && bundle install`
    before judging results.
16. **Check the repo's OWN CI history before blaming the wave.** mn-samples-jis
    was red in its own CI two weeks before the wave (doc-format errors);
    mn-samples-swf's flavor gem is missing upstream (lockout.txt); nist needs
    private GitHub Packages. Not wave regressions — documented, not chased.
17. **A samples repo without metanorma.yml/test.yml is not a smoke target**
    (swf had neither). Verify the config exists before invoking site generate.

18. **Lockfiles pin lutaml-model bugs too.** jis's committed lock held
    lutaml-model 0.8.165, whose XML mapping raises `Attribute 'id' not found in
    Relaton::Bib::Bibitem` on flavor bibitems — 9 render specs red. Refreshing
    to 0.8.169 fixed all 9. When a flavor suite crashes inside
    `apply_xml_mapping`, diff the lutaml-model version against a working
    bundle first.
19. **Precompiled css twins bake in DEFAULT fonts.** isodoc 3.7.9+ ships
    `.css` twins compiled with default variables; flavors overriding
    `default_fonts` were silently dropped. isodoc 3.7.12 prefers runtime scss
    compilation when sassc-embedded is in the bundle. Flavor font specs red
    since late Oct = this, not the current wave.
20. **Citation wording changes are drift, not bugs**: relaton 3.1 renders
    source URIs "Available at:" (was "Available from:") and formats bibitems
    with a trailing period. Rebaseline expected fixtures/strings accordingly.
21. **Dispatch tebako/packed builds only AFTER the pinned gem is on rubygems** —
    `sync-payload.rb` fails with "registry X entry has no version Y" otherwise.
