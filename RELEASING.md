# 🚀 Releasing

[![Versioning: SemVer](https://img.shields.io/badge/versioning-SemVer-1f3a5f)](#version-convention)
[![Published releases: none](https://img.shields.io/badge/published%20releases-none-6E7781)](#current-stage)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

This procedure covers versions, the changelog, integration into main, tags
and the evidence each stage needs. [Governance](docs/GOVERNANCE.md) owns
branches and milestones; this document owns what turns a milestone into a
version.

<a id="current-stage"></a>

## 📍 Current stage

No version has been tagged or published. v0.0.1 is the **repository setup
baseline**: labels, governance, settings, forms, CI and traffic analytics.
It is not a working or regulatory-validated calculator. v0.1.0 is the Excel/VBA
**SA prototype**; its LibreOffice evidence exists, but Excel host evidence
(#28), methodology decisions (#29) and the Excel round trip (#30) remain open.

<a id="version-convention"></a>

## 🔢 Version convention

| Item | Convention | Example |
| --- | --- | --- |
| Version number | [Semantic Versioning](https://semver.org/) `MAJOR.MINOR.PATCH`; before 1.0.0, MINOR marks a functional stage and PATCH a setup or maintenance increment | `0.0.1`, `0.1.0` |
| Pre-release | SemVer pre-release identifier | `0.1.0-prototype` |
| Milestone | Version plus a short title | `v0.1.0 - SA prototype` |
| Integration branch | `release/` plus the tag name | `release/v0.1.0` |
| Tag | `v` plus the version, annotated, on a main commit | `v0.0.1` |
| Changelog section | Version and release date | `## [0.0.1] - 2026-10-18` |

One convention applies to every line. Do not tag without the `v` prefix,
reuse a number, or tag a release branch.

## 📌 Version source

- **The tag** is the authoritative record of a released version once it
  exists. Tags `v*` are protected against update, deletion and force pushes
  ([settings](docs/REPOSITORY_SETTINGS.md)); a wrong tag is corrected by a new
  PATCH version, never by moving it.
- **The changelog** section heading must name the same version and date.
- **The workbook** reports its own version in `APP_VERSION`
  (`src/modules/CORE_Config.bas`); it must equal the tagged version, or carry
  the same version with a pre-release identifier, when a workbook version is
  tagged.

## 📝 Changelog

[CHANGELOG.md](CHANGELOG.md) collects integrated changes under
`[Unreleased]`. When the owner requests a release, a task PR moves the
entries that belong to that version into a dated version section. Main can
carry work from more than one line: move only the entries of the released
milestone and leave the others under `[Unreleased]`.

## 🔀 Integration and tagging

1. **Task PRs** squash-merge into the integration branch of their issue's
   milestone after the required `Repository integrity` check and the
   applicable checks pass and review findings are resolved.
2. **Milestone closeout**: the closeout issue reconciles every issue and PR
   and links the evidence below. Closing the milestone does not merge main,
   create a tag or publish a release.
3. **Integration into main** happens only on the owner's explicit request,
   through a release-to-main PR with a merge commit. The retained release
   branch is then fast-forwarded to that merge with an expected-head guard.
4. **Changelog cut**: on the owner's request, a task PR dates the version
   section, and it reaches main through step 3.
5. **Tag**: on the owner's request, create an annotated tag on the main
   commit that carries the dated section, then push it:

   ```sh
   git fetch origin
   git tag -a v0.0.1 <main-commit> -m "v0.0.1 - Repository setup"
   git push origin v0.0.1
   ```

   If main already carries later-stage work (for example the prototype
   source), the release notes must say that it is outside the tagged
   version's scope and evidence.
6. **GitHub release** (optional, on request): notes that link the closeout
   issue and evidence. Attach no workbook binary unless the version's
   evidence covers it.

## 📦 Contents and evidence by stage

| Stage | Release contents | Evidence required before tagging |
| --- | --- | --- |
| Setup (v0.0.x) | Source tree only; no binaries or workbooks | Closeout issue with merged PRs, green `Repository integrity` and label-drift runs, live settings readback, fresh-checkout verification and metadata audit |
| Prototype (v0.1.x) | Source tree and the committed macro-free template; no built `.xlsm` | Setup evidence, plus the LibreOffice reconciliation suite, Excel host build, compile and regression evidence (#28), the Excel round trip (#30) and recorded methodology decisions (#29) |
| Functional releases | Defined by the milestone that introduces them | Prototype evidence, plus independent benchmarks, the supported-host matrix and any packaging approved in [Scope](docs/SCOPE.md) |

Evidence is bound to a commit: it names the PR or commit, commands, results,
hosted run URLs, the settings readback date and anything not run. Static
checks do not prove runtime or numerical correctness, and LibreOffice runs
are not Excel evidence. Never fabricate workbook or Excel results.

## 🚫 Not part of a release

A tag or release does not change repository visibility, publish a website or
certify regulatory compliance. Each of those needs a separate owner decision.
