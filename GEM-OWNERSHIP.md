# Gem ownership in the released bundle

Classification of every non-platform gem in the metanorma Docker bundle
(`metanorma-debian/Gemfile.lock`, 2026-11-16). **RIBOSE** = maintained within
the Ribose ecosystem, grouped **by the GitHub organisation that owns the
gem's repository** — which is also the release-ownership unit: each org's
gems are released by that org's team. **external** = third-party gems we
depend on but never release.

Tier 0 rule: the metanorma team releases only the `metanorma` org's gems;
the relaton, lutaml, pubid, fontist, glossarist, leptris and claricle orgs
release their own.

## metanorma (47 gems)

- `cnccs`
- `fractor`
- `gb-agencies`
- `html2doc`
- `isodoc`
- `isodoc-i18n`
- `isoics`
- `metanorma`
- `metanorma-bipm`
- `metanorma-cc`
- `metanorma-core`
- `metanorma-document`
- `metanorma-gb`
- `metanorma-generic`
- `metanorma-iec`
- `metanorma-ieee`
- `metanorma-ietf`
- `metanorma-ietf-data`
- `metanorma-iho`
- `metanorma-iso`
- `metanorma-itu`
- `metanorma-jis`
- `metanorma-m3aawg`
- `metanorma-mirror`
- `metanorma-ogc`
- `metanorma-oiml`
- `metanorma-plateau`
- `metanorma-plugin-glossarist`
- `metanorma-plugin-lutaml`
- `metanorma-plugin-openapi`
- `metanorma-plugin-plantuml`
- `metanorma-release`
- `metanorma-ribose`
- `metanorma-standoc`
- `metanorma-taste`
- `metanorma-un`
- `metanorma-utils`
- `mn-requirements`
- `mn2pdf`
- `mnconvert`
- `niso-jats`
- `relaton-iev`
- `rfcxml`
- `sts`
- `suma`
- `uniword`
- `vectory`

## lutaml (17 gems)

- `canon`
- `coradoc`
- `ea`
- `lutaml-hal`
- `lutaml-jsonschema`
- `lutaml-lml`
- `lutaml-model`
- `lutaml-openapi`
- `lutaml-path`
- `lutaml-store`
- `lutaml-uml`
- `moxml`
- `oasis-etm`
- `ogc-gml`
- `oscal`
- `unibuf`
- `xmi`

## claricle (8 gems)

- `emf`
- `emfsvg`
- `lens_core`
- `libpng`
- `png_conform`
- `postscript`
- `postsvg`
- `svg_conform`

## plurimath (7 gems)

- `amath`
- `latexmath`
- `mml`
- `omml`
- `plane1converter`
- `plurimath`
- `umath`

## relaton (4 gems)

- `ieee-idams`
- `loc_mods`
- `relaton`
- `w3c_api`

## unitsml (3 gems)

- `asciiunits`
- `unitsdb`
- `unitsml`

## omnizip (3 gems)

- `cabriolet`
- `excavate`
- `omnizip`

## fontist (2 gems)

- `fontisan`
- `fontist`

## glossarist (2 gems)

- `glossarist`
- `tbx`

## metanorma (52 gems)

- `metanorma-cli`

## pubid (1 gems)

- `pubid`
