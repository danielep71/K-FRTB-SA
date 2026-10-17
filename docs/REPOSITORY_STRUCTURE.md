# Repository structure and file policy

This document owns placement of durable source, generated files, and evidence.
[Scope](SCOPE.md) owns platform and functional decisions;
[installation](../INSTALLATION.md) owns the available setup commands.
The layout separates source, tests, documentation, and tools without
assuming an engine runtime.

## Current layout

| Path | Purpose today and intended content |
| --- | --- |
| `src/` | Source boundary for future production components; currently guidance only |
| `src/workbook/` | Reserved workbook-template location and its policy; no workbook exists |
| `tests/` | Verification-source and synthetic-data policy; no calculation harness or cases yet |
| `docs/` | Authoritative versioned scope, governance, structure, and milestone documentation |
| `tools/` | Tooling index and placement policy; current executable label tooling remains in `.github/scripts/` |
| `.github/` | Label manifests, scripts, and workflows |
| Root | Entry documentation, licenses, contribution/setup guidance, and repository-control files |

Each new root has a purposeful README. Add further subdirectories with their
first real file and documented purpose, rather than creating empty engine
modules, fixtures, or placeholder test runners. Source extensions, runtime
dependencies, and build commands must follow an approved platform decision.
The label catalogue's `application` profile is not an engine architecture
decision.

## Source of truth

Reviewable production source belongs in `src/`; test source and independently
specified expected results belong in `tests/`. Tools must not become a second
calculation engine. Versioned documents govern the repository; issue discussions
record decisions and evidence and should link to the resulting source.

Do not commit client portfolios, real counterparty identifiers, production
exports, credentials, private keys, or unsanitized logs. Examples and fixtures
must be synthetic and document their origin and usage rights.
An ignore rule is a tracking aid, not a data-security control.

## Generated files, workbooks, and evidence

| Material | Policy |
| --- | --- |
| Generated build/release packages | Keep local output under ignored root `build/`, `dist/`, or `release-assets/`; publish only through a separately approved release procedure |
| Test run output | Keep disposable output under ignored root `test-results/` or `test-output/` |
| Durable reviewed evidence | Add selected sanitized records under `docs/evidence/` with their first real record; record commit, environment, commands, results, and limitations |
| Synthetic test inputs and expected values | Add `tests/fixtures/` and `tests/expected/` when real cases exist; record independent provenance, units, signs, tolerances, and reference versions |
| Excel workbooks, add-ins, and templates | Ignored by default; only `src/workbook/FRTB_Template.xlsx` is currently allowed by exact rooted exception |
| Local dependencies and environments | Ignored caches/installations; commit necessary manifests and locks when a real ecosystem is introduced |

The workbook exception reserves a path; it is not an existing artifact,
supported engine, or approval to distribute other workbook files. A future
template change needs a reviewable explanation of sheets, names, formulas,
data, and compatibility because Git treats Office packages as binary.
Never include confidential inputs or hidden credentials in a template.

Evidence must bind to the reviewed commit and identify what ran. A static
check is not runtime execution. Future numerical expected values must come
from a published reference or a separately derived calculation, never the
implementation under test. Missing or skipped execution is not a pass.
Do not retain every disposable log as authoritative evidence.

## Editing and Git behavior

The root controls already define:

- `.editorconfig`: LF for documentation/configuration/tooling, 2-space
  indentation for JavaScript/JSON/YAML, and CRLF/4 spaces for exported VBA.
- `.gitattributes`: text normalization, VBA working-tree CRLF and diff driver,
  LF supporting text, and binary Office packages/UserForm companions.
- `.gitignore`: generated output, Office locks, secrets, caches, and local
  environments, with the exact approved workbook-template exception.

VBA encoding is intentionally not forced. Do not add working-tree encoding
or renormalize existing files without a separate justified compatibility
check. Markdown may retain intentional hard-break spaces.
The settings describe file handling; they do not select an engine platform.

## Conditional Excel/VBA policy

If Excel/VBA is selected, record its supported hosts and build/import procedure
before claiming workbook support. The following source-first requirements
apply to that decision:

1. Commit reviewable exported `.bas`, `.cls`, and `.frm` files under
   documented source roots. Keep each required `.frx` beside its `.frm`.
   Include workbook and sheet document-module code; a binary workbook must
   never be the only record of a code change.
2. Keep the macro-free template at the approved path and construct local
   runnable workbooks from the template and reviewed exported source.
   Document component names, import order, sheet CodeNames, references,
   encoding, and production-versus-test component selection.
3. Export workbook edits back to reviewable source before committing.
   Verify a source-to-workbook-to-export round trip against the candidate
   commit, recording workbook/template digests and comparison limitations.
   Never silently overwrite workbook code or treat a source-only rebind as
   proof of a new runtime run.
4. Require actual host compilation and scenario/test execution for VBA
   changes. Evidence identifies the exact commit, Excel/OS/bitness,
   workbook digest, suites/assertions, results, failures, and skipped work.
   Independently specified numeric expectations remain a separate requirement.

No synchronizer, exporter, workbook, Excel harness, or runtime gate is
implemented at setup time. Add them through scoped implementation issues when
the platform is selected.
