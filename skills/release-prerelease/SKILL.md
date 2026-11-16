---
name: release-prerelease
description: Act 2 of the staged release program — publish metanorma-cli as a prerelease (owner-stated .pre. version, minimal gemspec locks derived from the staged wave), build the pre-release docker image, and post a CALL FOR TESTING so end users can test their documents before anything goes live. Use after /release-fleet staged the fleet. Not the live announcement.
argument-hint: <pre-version>
disable-model-invocation: true
---

Execute Act 2 of the staged program: put a user-testable prerelease of
metanorma-cli into end users' hands. The recipe is
`${CLAUDE_PLUGIN_ROOT}/3-release-wave.md` § "Act 2"; the paste-ready
form is Prompt A of `${CLAUDE_PLUGIN_ROOT}/9-prerelease-prompt.md`.
Read docs 1-6 plus that section first. The goal to keep in view at
every step: end users compile THEIR documents on this cli and report
findings while nothing is live.

Sequence:
1. Version: the argument, in the fleet's `.pre.` date form. Refuse and
   ask if it is not a prerelease version or was not stated by the owner.
2. Gemspec locks: derive the minimal lock set from cli's DIRECT runtime
   dependencies — `~>` at the minor the Act-1 tier-3 gate validated for
   each. Never exact pins, never transitive/dev deps, never flavor gems
   cli does not load. PRESENT the derived lock plan to the owner and
   wait for approval before any gemspec commit.
3. Release cli as the prerelease via its release.yml; verify the exact
   version is fetchable from rubygems.
4. Build and push the prerelease docker image (default tag: the version
   string), run the per-flavor smokes on it, and record evidence.
5. GitHub Release for the cli prerelease, marked PRE-RELEASE (not
   Latest).
6. Draft the CALL FOR TESTING for metanorma/discussions — install and
   docker-compile instructions, what changed, the feedback channel — and
   show the draft to the owner before posting. This is an invitation,
   not the release announcement.

The wave tracker stays open; record the prerelease state and the
feedback window on it. Findings during the window fix forward: fleet
fixes re-run the Act-1 gates as needed, and each iteration is a new
dated prerelease — never a re-push of the same version (rubygems never
re-admits a version number). The live announcement belongs to Act 3
(`/release <final>`), not to this skill.
