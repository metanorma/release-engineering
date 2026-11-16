# 2 — The PR wave (how the code changes get in)

## Conventions

- Branch names: `fix/<topic>` or `purge-pre-pins` style; one concern per PR.
- Commit messages: one line, no AI attribution, no trailers.
- Stage by EXPLICIT path (`git add file.rb`) — never `git add -A`.
- PR bodies via `gh pr create --body-file /tmp/body.md` — NEVER inline bodies
  containing backticks (shell substitution leak; see the 2026-07-22 incident).
- Merge: rebase (`gh pr merge --rebase`). Merge-on-green monitors poll
  `statusCheckRollup` — merge only at 0 pending AND 0 failed — unless the
  owner authorizes direct merges (`--rebase --admin`).
- After a rebase-merge, pushing to the merged branch does NOT reach main —
  open a fresh PR for deltas.
- **Instant-PR pattern** (owner rule): when a fix must land mid-wave, create
  the PR, rebase-merge it immediately (`--rebase --admin`), and CANCEL the
  PR's CI runs completely right after the merge — those tests are moot once
  the change is on main and they hog the runner queue. Never forget the PR
  number on `gh pr merge <num> --repo <repo>` (a dropped number fails with
  "argument required when using the --repo flag" and leaves the PR open).
  Re-dispatch any release ONLY after the merge actually landed.
- `gh run rerun` replays the SNAPSHOTTED reusable workflow; after merging a
  reusable-workflow fix, dispatch a FRESH run instead.

## The 2026-11-06 wave (what it looked like)

| Layer | PR | Change |
|---|---|---|
| isodoc | #884 | canonical requires (`relaton`, `relaton/bib`, `relaton/cli` in metadata_bibdata), floor `~> 3.1.1` |
| metanorma core | #660 | same canonicalization (metanorma.rb, collection files), parsanol hold `1.3.114` → `~> 1.3.129` |
| metanorma-standoc | #1344 | REMOVE metanorma-plugin-asciichem (drags asciichem → relaton-bib), floors, Gemfile pins |
| mn-requirements | #61 | `relaton ~> 3.1.1` (released 0.5.14 declared `relaton-render ~> 3.0.0.pre.alpha` — the last transitive puller) |
| metanorma-release | #23 | relaton-bib → `relaton ~> 3.1.1` + rubyzip-3 API migration (`Zip::File.open(create: true)`, `Entry#extract` semantics) |
| plugin-datastruct | #82 | deleted vestigial `relaton-cli` (code never used it — grep first, don't assume) |
| plugin-glossarist | #106 | `glossarist ~> 2.14` (real line) |
| stepmod-utils | #285 | `pubid ~> 2.0` (real line) |
| metanorma-document | #110 | `glossarist ~> 2.14` + `relaton ~> 3.1.1` |
| metanorma-cli | #484 | real `~>` floors replacing the `.pre` wall; `relaton-cli >= 3.0.0` → `relaton ~> 3.1.1` |
| metanorma/ci | #484 | sample-test Gemfile injection floors `relaton ~> 3.1.1` |
| flavors (Gemfile only) | iec#609, bsi#661, oiml#41, iso#1693, csa#366 | `.pre` Gemfile pins → real releases; iec needed a plugin-lutaml lock refresh to even resolve |
| flavors (gemspec) | ietf, gb | ietf `relaton ~> 3.1.1`; gb's impossible `isodoc ~> 0.8.8` → `~> 3.7` |

## Finding stale declarations (the sweep recipes)

```bash
# gemspecs with retired gems or prerelease versions, org-wide
gh api "search/code?q=org:metanorma+relaton-render+filename:gemspec" --jq '.items[].repository.full_name'
gh api "search/code?q=org:metanorma+%22.pre%22+filename:gemspec" --jq '.items[].path'

# Gemfiles
gh api "search/code?q=org:metanorma+%22.pre%22+filename:Gemfile"

# code requires (the crash surface)
gh api "search/code?q=org:metanorma+%22require+%5C%22relaton-cli%5C%22%22+language:ruby"
```

Then verify each candidate's main branch directly — code search indexes lag.

## Who owns what (do NOT file there)

- relaton, glossarist (glossarist-ruby), fontist: their teams own the gems.
  Watch their releases; never PR them (a stray PR gets closed with apology).
- Everything metanorma/* is ours.

## Reading bundler solver failures (they name the culprit)

A `Could not find compatible versions` block chains the whole conflict:
e.g. "glossarist >= 2.14.0 depends on relaton ~> 3.0.0.pre.alpha … every
version of metanorma depends on relaton ~> 3.1 … version solving has failed."
Read it bottom-up: the LAST constraint pair is the actionable conflict.
