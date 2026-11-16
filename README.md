# metanorma/release-process

The metanorma release flow: documentation, gates, wave tracker, and tools.
Everything a maintainer (or an AI agent) needs to run a fully validated
release wave, from leaf gems to the Docker image, registries, and
communications.

## Install as a Claude Code plugin

This repo is also a Claude Code plugin and its own marketplace. Any
maintainer installs it with:

```
/plugin marketplace add metanorma/release-process
/plugin install metanorma-release@release-process
```

Skills (invoke as `/metanorma-release:<name>`, or bare `/release` when
unambiguous):

| Skill | Scope |
|---|---|
| `/release` | full validated release wave, tiers 1-6 (human-initiated only) |
| `/release-smoke` | zero-side-effect dry run of the whole flow |
| `/samples-gate <repos…>` | Tier-3 local gate for one repo / one flavor |
| `/release-verify <version>` | post-release registries + artifacts sweep |
| `/wave-report v<prev> v<wave>` | ledger + changelog tracker comments |
| `/release-status` | read-only "where are we" state report |

Authorization stays human regardless of skill: version numbers,
go/no-go on releases, and anything irreversible are owner decisions the
skills are written to enforce.

## Start here (without the plugin)

1. Read the docs in order: `1-overview.md`, `2-pr-wave.md`,
   `3-release-wave.md`, `4-local-samples-validation.md`,
   `5-cli-docker-close-out.md`, `6-troubleshooting.md`.
2. Copy the fenced prompt in `7-release-prompt.md` and hand it to the AI
   agent with two inputs: the target metanorma-cli version (the owner's
   decision — patch bumps may follow version.rb; anything else waits for
   an explicit number) and where the tracker lives (metanorma/discussions
   by default).
3. The agent opens the wave tracker from `wave-tracker-template.md` at
   step 0 and keeps the mermaid stage classes and checkboxes in sync at
   every gate.
4. Deliverables: the FULL PROPER REPORT (defined at the end of the
   prompt), plus two tracker comments — `gem-ledger.rb` output (the
   all-gems version table diffed against the previous wave) and
   `gem-changelog.rb` output (per-gem changelog + wave summary, with a
   one-paragraph narrative written at close-out).

A release is not done until the registries and communications reflect it.

## Tools

- `gem-ledger.rb v<prev> v<wave>` — version table for every Ribose-managed
  gem (per `GEM-OWNERSHIP.md`, grouped by org), diffed against the
  previous wave's frozen docker bundle. Prints ready-to-post markdown.
- `gem-changelog.rb v<prev> v<wave>` — per-gem changelog (GitHub Release
  notes when present, otherwise tag-compare subjects) plus a mechanical
  wave summary. Flags gems shipped to rubygems without their git tag.
  Prints ready-to-post markdown.
- Packed releases: `packed-metanorma/tools/sync-payload.rb` (tebako
  payload version sync; lives in the packed-metanorma repo).

## Pilot

`release-process#1` is the pilot tracker (the 1.18.6 wave, recorded
retroactively). The next real wave opens its tracker in
metanorma/discussions from `wave-tracker-template.md`.
