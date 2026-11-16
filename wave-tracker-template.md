# Release wave tracker — TEMPLATE

Copy this into a NEW public Discussion in **metanorma/discussions**
(category: Announcements) at the start of every release wave, and edit the
Discussion body at each stage transition. The checkboxes mirror the oracles
(rubygems / CI runs / git tags) — never record state the oracles do not show.

## Title

`Release wave YYYY-MM-DD: <short name> (cli X.Y.Z)`

## Body template

````markdown
### Pipeline status

```mermaid
flowchart LR
  classDef done fill:#2da44e,color:#fff,stroke:#2da44e;
  classDef active fill:#bf8700,color:#fff,stroke:#bf8700;
  classDef pending fill:#d0d7de,color:#57606a,stroke:#afb8c1;
  S0[Stability]:::pending --> S1[Local test]:::pending --> S2[mn-samples wave]:::pending
  S2 --> S3[Release waves T1-T4]:::pending --> S4[Docker + versions]:::pending
  S4 --> S5[Comms + close-out]:::pending
```

### Faces in this wave

| Gem | Tier | Target version | State |
|---|---|---|---|

### Tier 1 — leaf libs
- [ ] gem — vX.Y.Z on rubygems — GitHub Release

### Tier 2 — flavors
- [ ] metanorma-iso — vX.Y.Z — …

### Tier 3 — mn-samples local validation
- [ ] repo — bundle OK — forbidden-grep 0 — render OK — html count N

### Tier 4 — cli
- [ ] metanorma-cli vX.Y.Z

### Tier 5 — docker + registries
- [ ] release-tag dispatched
- [ ] publish log: Installing <gem> <version> for every bundled gem
- [ ] Hub digest moved
- [ ] metanorma/versions lockfile published

### Tier 6 — communications + close-out
- [ ] GitHub Releases verified (Latest marker on the new tag)
- [ ] metanorma/discussions announcement posted (link)
- [ ] metanorma.org blog post (link)
- [ ] reporter per-issue confirmations
- [ ] packed/tebako state recorded

### Version ledger

| Gem | Version | Released at | Notes |
|---|---|---|---|

### Reports
(per-document validation catalogs, PDF confirmations, container confirmations)
```

## Rules

1. Open the Discussion when the wave reaches `planned` (ancora) or the
   maintainer names the faces; edit the BODY at each transition — comments
   are for the final report and user questions.
2. The mermaid stage classes move pending → active → done as the gates pass.
3. Never check a box the oracle does not show; the tracker mirrors reality.
4. Cross-link: the GitHub Release of the cli cites the tracker; the tracker
   cites the announcement and blog post.
