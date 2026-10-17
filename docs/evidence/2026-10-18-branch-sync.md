# 🔄 Setup/prototype synchronization inputs

Issue #31 owns the live implementation PR, candidate/merge commit, hosted
check results and branch-cleanup evidence for this synchronization.

## Source snapshots

| Line | Source commit | Content to retain |
| --- | --- | --- |
| Main/setup after #36 | `7ee0cedd4276e500effe7efdbdac2164ffd70a68` | Forms/policies, label guard, universal CI, dependency updates and main-only analytics tooling |
| Prototype after #34 | `3a24b3caa032cd72a1ea979345d9a757bd910450` | Template, src/modules, independent reference, workbook/LibreOffice tooling and prototype documentation |

Production/test VBA, the committed template, prototype reference and build
helpers are preserved byte-for-byte from the prototype snapshot. This task
changes shared documentation, contribution forms and the prototype workflow's
installation of the separate CI parser; it makes no calculation change.

The main maintenance scripts and privileged analytics workflows are copied
without changing their trust boundary. Documentation is reconciled against
both lines instead of retaining contradictory setup-only capability claims.
Forms describe the prototype and pending Excel evidence; the PR checklist
selects the integration branch of the issue's milestone.

## Content and history verification

Before merging, compare the candidate tree to both source trees: every main
path must exist, maintenance code/configuration must match except the named
form/documentation adaptations, and prototype source/assets must retain
their blob IDs. Record candidate and result commits in #31. A squash task
merge keeps the prototype's existing history, but does not make the main
source head an ancestor. This is content synchronization, not ancestry
advancement or an integration of the prototype into main.

## Superseded task branch

`feat/sa-workbook-prototype` at `1f90d1320da18f7f54d19a0bb015911123a2079b`
is an ancestor of PR #22's reviewed head
`e9ed139bbd915ad0ef0da594a2f9b436ba1ea377` (13 commits ahead, none behind).
That reviewed head and its squash merge
`7f6f15ab34ba054c00fe4902f2dbc6db4ddd0959` have the same tree,
`e74fde001257cd44e4b9de37e5d730b65b9bb086`.
The reviewed work is therefore retained; re-read the branch head before
deleting it and stop if it has advanced. Record the actual deletion in #31;
this record alone does not claim it has occurred.

## Evidence limits

Local checks cover maintenance and VBA static lint. The hosted prototype
suite must provide the full LibreOffice results on the candidate. Excel
execution/export remains #28/#30; methodology decisions remain #29, required
status-check enforcement remains #2, and traffic credentials/first collection
remain deferred in #23. No tag, release, website or workbook publication is
part of this task.
