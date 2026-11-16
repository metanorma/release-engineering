---
name: release-verify
description: Verify an already-shipped metanorma release's registries and artifacts — GitHub Releases Latest markers, Docker Hub digest, publish-job logs, metanorma/versions lockfile. Read-only sweep. Use after a release ships or when a consumer reports version confusion.
argument-hint: <version>
---

Execute the release verification sweep for the version in the arguments.

1. Read `${CLAUDE_PLUGIN_ROOT}/5-cli-docker-close-out.md` — its GitHub
   Releases verify/backfill recipe, docker deep verification, and
   metanorma/versions sections are the oracle definitions.

Sweep, and report evidence for each:
- Every repo released in the wave: `gh release list` shows the new tag
  with the correct Latest marker (newest = Latest, all others not).
- Docker Hub: the image digest moved at the expected time.
- The docker build's publish-job log: grep
  `Installing <gem> <version>` for every bundled gem — a rerun can push
  stale content while the digest still moves.
- Float guard: the frozen bundle matches the released lock, no gem
  drifted between tag and publish.
- metanorma/versions: the lockfile manifest for this version is
  published (actions-mn/setup consumes it).

DISCREPANCIES: report each with evidence, then STOP. Fixes (gh release
backfill, the docker tag-rerun refresh flow) touch shared state and run
only on explicit owner go-ahead. Never "quietly fix" a registry.
