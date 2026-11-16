# 8 — Smoke test: dry run of the release prompt

Run this BEFORE the first real wave on this flow (or after major edits to
the docs). It exercises the entire flow with zero side effects: the agent
proves it can execute every gate and produce every report without
dispatching anything.

```
SMOKE TEST — DRY RUN of the metanorma release flow (dispatch NOTHING)

Read ~/src/mn/release-process/README.md, then docs 1-6 in order, then
execute the fenced prompt in 7-release-prompt.md under the overrides
below. This is a rehearsal: prove the flow end to end with ZERO side
effects. Where this prompt and 7-release-prompt.md conflict, THIS wins.

TARGET: metanorma-cli 1.18.7 (hypothetical: version.rb + 1 from 1.18.6).
Simulate its wave; release nothing.

HARD RULES (in addition to the prompt's RULES):
- No release.yml dispatches, no git tags, no pushes to main, no gem
  publishes, no docker builds/pushes, no metanorma/versions writes.
- No public communications: nothing in metanorma/discussions, no blog
  post, no comments on reporter or user issues, no issue closures.
- The ONLY permitted shared-state writes: the smoke tracker issue
  (step 0) and process-gap issues in metanorma/release-process itself.
- Anything the docs prescribe that would touch shared state and is not
  allowed above: SKIP it, and record the skip on the tracker.

STEP 0 — TRACKER: open ONE issue in metanorma/release-process titled
"[smoke] 1.18.7 dry run — <today's date>". Build its body from
wave-tracker-template.md. Keep the mermaid stage classes and checkboxes
in sync at every gate, exactly as a real wave would.

STATE CHECK: run fully — `gem list -r` across every tier-1/2 gem, each
repo's version.rb, release.yml existence. Deliverable: the release
manifest this wave WOULD run (every gem with main-ahead fixes vs its
released version, in tier order).

TIERS:
1-2. Produce the release manifest (order, versions, dependency notes);
     dispatch nothing.
3. Exercise the LOCAL gate machinery end-to-end on ONE small mn-samples
   repo (bundle → forbidden-grep == 0 → render, released gems + cli git
   main, exactly as 4-local-samples-validation.md prescribes) and record
   its evidence. List every other repo as "not exercised (dry run)".
4. cli: nothing to dispatch; record the gate that WOULD apply (T3 fully
   green) and its status.
5. docker: read-only verification only — release workflow present, the
   current Hub digest recorded. Dispatch nothing.
6. Run BOTH tools against the REAL tags v1.18.5 → v1.18.6 (this tests
   the tooling, which is the point of tier 6 here) and post their
   outputs plus a one-paragraph wave narrative as tracker comments.
   Assemble the FULL PROPER REPORT with [dry-run] annotations on every
   artifact a real wave would publish elsewhere; post it as the final
   tracker comment.

CLOSE: close the smoke issue with a one-comment verdict: what the flow
got right, every gap or ambiguity hit in the docs (file ONE issue per
gap in metanorma/release-process), and the straight answer: would this
flow have produced a correct, complete, verifiable release?

DONE WHEN the smoke issue shows: the synced tracker (mermaid states),
the release manifest, one repo's gate evidence, both tool outputs, the
annotated full report, and the closing verdict — and nothing anywhere
else in the fleet moved.
```
