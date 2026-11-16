---
name: samples-gate
description: Run the Tier-3 local validation gate for one or more mn-samples repos (e.g. a single flavor) — bundle, forbidden-grep, render, per-repo evidence. Use for "test one flavor", pre-release spot checks, or re-running a failed gate. Not for full waves or dispatching releases.
argument-hint: <repo...> [--full]
---

Execute the Tier-3 local gate exactly as documented in this plugin.

1. Read `${CLAUDE_PLUGIN_ROOT}/4-local-samples-validation.md` and
   `${CLAUDE_PLUGIN_ROOT}/1-overview.md` (golden rules).
2. Repos: the arguments, or the full roster with `--full` (roster and
   the pre-existing-red list are in doc 4).

Recipe, per repo — never deviate:
- Worktrees from `origin/main` ONLY. Local clones can sit on stale
  experiment branches with fossil Gemfiles; never reuse them.
- Stack: released gems + metanorma-cli @ git main, nothing else.
- bundle → forbidden-grep == 0 → config-selected render → record
  PASS/FAIL with the html count.

Precondition (flavor-only intent): before starting, check whether any
tier-1 lib (metanorma, metanorma-standoc, isodoc, metanorma-document,
relaton, pubid, lutaml-model) has main-ahead commits. If yes and the
caller asked for a lone-flavor result, STOP and explain the version-skew
risk — a flavor rendered against unreleased leaf libs does not predict
its released behavior. Proceed only on explicit owner instruction.

Failures are fixed at SOURCE, not in the gate. Pre-existing reds (doc 4
list) are recorded as pre-existing, not fixed here. Post the evidence
table where the caller directs; per-document validation catalogs stay
SEPARATE per document, never merged.
