## 🎯 Objective and scope

Related issue:
Explain the problem and resulting behavior. State non-goals and compatibility
impact (inputs, outputs, defaults, errors, formats, supported environments).

## 🧪 Validation

Record the exact source commit, commands, results, and relevant run/evidence
links. Distinguish static checks, runtime execution, independent numerical
comparison, and methodology review. State anything unavailable or skipped.

## 🔍 Review findings and limitations

Link findings and explain their resolution. Identify unresolved findings,
risks, dependencies, or missing evidence; write None when applicable.

## ✅ Merge checklist

- [ ] Base is `release/v0.0.1` for a task, or this is an explicitly owner-requested release-to-main integration.
- [ ] Linked issue and PR have assignee `danielep71`, exactly one priority, and the appropriate milestone; P1 is only for confirmed calculation bugs.
- [ ] Scope, compatibility impact, affected documentation, and CHANGELOG.md are current.
- [ ] Applicable checks pass; any running automated review is finished and all review findings are addressed or explained and resolved.
- [ ] Evidence and limitations are accurate; no credentials, confidential data, or undisclosed vulnerability details are included.

Task PRs squash-merge into the integration branch. Owner-requested main
integrations use a merge commit and retain/fast-forward the release branch.
See [governance](https://github.com/danielep71/MKT-FTRB-SA/blob/main/docs/GOVERNANCE.md).
