# Contributing

Changes to this repo change how every metanorma release runs. The bar is
deliberately high and deliberately simple.

## What changes here

- **Gates and rules** (docs 1-6): how releases are validated. Gate changes
  need the owner's ruling recorded in the change itself — a gate without a
  stated reason is a gate nobody can defend.
- **Skills** (`skills/*/SKILL.md`): thin routers over the docs. A skill
  adds invocation and safety rails, never a second source of truth — if
  the skill and a doc disagree, the doc wins and the skill is the bug.
- **Prompts** (docs 7-9): paste-ready forms of the same recipes. They stay
  location-independent (`<RELEASE-PROCESS>` convention) and DRY with the
  skills: one recipe, two entry points, one wording.
- **Tools** (`gem-ledger.rb`, `gem-changelog.rb`): mechanical, stdlib-only,
  deterministic. Their output is posted verbatim; anything you would
  hand-edit in the output belongs in the tool.

## The one mandatory gate

After ANY substantial edit to docs, skills, or tools, run the smoke test
(`/release-smoke`, or Prompt 8 in a fresh session) before the next real
wave. The smoke test exists to catch documentation drift with zero side
effects; skipping it re-runs the experiment on production.

## Validation

CI runs on every push: plugin manifests, skill frontmatter, tool syntax,
and the no-machine-paths rule. Keep it green; keep it fast.

## Ground rules

- Version numbers and release authorizations are the owner's decisions;
  nothing here changes that.
- The repo is BSD-2-Clause (fleet standard); contributions under the same.

## Ribose Contributor License Agreement

Before your first pull request can be merged in any Ribose GitHub
organization, you need to be covered by the Ribose Contributor License
Agreement (CLA). Sign once; one signature covers every Ribose
organization.

- **Individual contributors** — sign the Individual CLA at
  <https://cla.ribose.com/icla>. The `cla/ribose` check on your pull
  request reports the state, and you can also sign from the pull request
  by commenting `@ribose-cla agree` and completing the one-click link
  the App replies with.
- **Corporate contributors** — if your employer has an executed
  Organization CLA, the employer's Point of Contact adds your GitHub
  handle to its Schedule A at
  <https://cla.ribose.com/organizations>, or you can request coverage
  there yourself. No individual signature is then needed.
- **The full guide** — the signing flows and the agreement text are at
  <https://github.com/riboseinc/cla/blob/main/docs/SIGNING.md>.
