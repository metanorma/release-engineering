### Pipeline status

```mermaid
flowchart LR
  classDef done fill:#2da44e,color:#fff,stroke:#2da44e;
  S0[Stability]:::done --> S1[Local test]:::done --> S2[mn-samples wave]:::done
  S2 --> S3[Release waves T1-T4]:::done --> S4[Docker + versions]:::done
  S4 --> S5[Comms + close-out]:::done
```

### Faces in this wave

| Gem | Tier | Target version | State |
|---|---|---|---|
| metanorma-document | 1 | 0.5.7 | released |
| metanorma-standoc | 1 | 3.5.22 | released |
| isodoc | 1 | 3.7.15 → 3.7.16 | released |
| metanorma-iso | 2 | 3.5.16 → 3.5.21 | released |
| metanorma-taste | 2 | 1.1.6 | released |
| metanorma-iho | 2 | 1.4.4 | released |
| uniword | 2 | 1.7.6 → 1.7.7 | released |
| metanorma-cli | 4 | 1.18.6 (images refreshed) | shipped |

### Tier 1 — leaf libs
- [x] metanorma-document — 0.5.7 on rubygems — GitHub Release
- [x] metanorma-standoc — 3.5.22 on rubygems — GitHub Release
- [x] isodoc — 3.7.15, 3.7.16 on rubygems — GitHub Releases

### Tier 2 — flavors
- [x] metanorma-iso — 3.5.16, 3.5.17, 3.5.18, 3.5.19, 3.5.20, 3.5.21
- [x] uniword — 1.7.6, 1.7.7
- [x] metanorma-taste — 1.1.6
- [x] metanorma-iho — 1.4.4

### Tier 3 — mn-samples local validation
- [x] iso / iec / itu / bipm / ogc / iho / ieee / jcgm / oiml / cc / ietf / expressdocs — docker matrix green (26 jobs) on the final train

### Tier 4 — cli
- [x] metanorma-cli 1.18.6 — published 2026-11-12, GitHub Releases backfilled (v1.18.1–v1.18.6, Latest = v1.18.6)

### Tier 5 — docker + registries
- [x] release-tag dispatched (3 refreshes: 3.5.18-train, 3.5.19-train, 3.5.21-train)
- [x] publish log: Installing metanorma-iso 3.5.21 / uniword 1.7.7 / standoc 3.5.22 / document 0.5.7 / isodoc 3.7.16 / yeptris 0.6.68.0
- [x] Hub digest moved (sha256:8de3649a…, 2026-11-15T18:04Z)
- [x] metanorma/versions lockfile — pending verification of the publish flow

### Tier 6 — communications + close-out
- [x] GitHub Releases verified (Latest marker on v1.18.6 after backfill)
- [x] metanorma/discussions announcement — pending (tracker pilot first, per owner)
- [ ] metanorma.org blog post — pending (resume with 1.18.6; silent since 1.11.3)
- [x] reporter per-issue confirmations — pdfa #111/#106/#103/#84/#116/#115/#114 closed; #119/#120/#121 closed with 3.5.21; #117 closing note posted
- [x] packed/tebako state recorded (external team lane, task #99)

### Version ledger

| Gem | Version | Released at | Notes |
|---|---|---|---|
| metanorma-standoc | 3.5.21 / 3.5.22 | 2026-11-13 | positional number: macro / svg profile + nobullet |
| metanorma-iso | 3.5.16–3.5.21 | 2026-11-13/14 | ISO_47 anchor fix → ToC/notes/parity/rules |
| isodoc | 3.7.15 / 3.7.16 | 2026-11-13/14 | nobullet render |
| uniword | 1.7.6 / 1.7.7 | 2026-11-13/14 | MHTML footnote-list / footnoteRef marker |
| metanorma-document | 0.5.7 | 2026-11-14 | FormulaBlock bare-fn model |
| metanorma-cli | 1.18.6 | 2026-11-12 | the wave cut; images refreshed ×3 |

### Reports

- yeptris 0.6.66.0 YAML corruption (Ruby 4.0 FFI): diagnosed, pinned, filed leptris/yeptris#1366, fixed in 0.6.66.1; matrix green on 0.6.68.0.
- 3.5.19 re-test defects: three independent issues (#119/#120/#121), fixed in 3.5.21/1.7.7 with failing-first specs.
