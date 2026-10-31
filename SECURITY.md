# 🛡️ Security policy

[![Stage: prototype](https://img.shields.io/badge/stage-prototype-1D76DB)](README.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

## 📦 Supported scope

| Material | Security maintenance status |
| --- | --- |
| Current `main` and active `release/v0.2.0` source and maintenance tooling | Reports accepted, and triaged by me |
| Historical commits, including the deleted setup branch `release/v0.0.1` and the superseded `release/v0.1.0`, or unmaintained task branches | No separate backport commitment; report issues that also affect current maintained source |
| Calculation engine, workbook, or packaged releases | None published or supported yet |

I maintain this prototype alone; it is not a managed security service.
There is no guaranteed response or remediation time and no bug-bounty program.

## 🔒 Report privately

Use [GitHub private vulnerability reporting](https://github.com/danielep71/K-FRTB-SA/security/advisories/new).
This channel was verified enabled in repository security settings on
October 18, 2026 (Europe/Rome). It permits private discussion with me;
do not publish the report as an advisory yourself.

Include the affected commit/branch, relevant component, prerequisites,
minimal synthetic reproduction, expected/observed behavior, potential impact,
and any proposed mitigation. Provide only the sensitive detail necessary
to reproduce the issue; never submit live credentials, client data, or
unrelated private information.

Do not post undisclosed vulnerabilities in public issues, PRs, comments, or
attachments. For ordinary non-security defects, use the bug issue form.

If the private-report link is unavailable, do not fall back to a public issue.
For an exposed credential or an account/platform security incident, contact
[GitHub Support](https://support.github.com/) and revoke/rotate the affected
credential through its issuing service. Support handles platform/account
incidents; it is not a substitute project vulnerability inbox.

## 🔎 Handling and disclosure

I assess the report, ask for missing reproduction detail, and coordinate
a fix and disclosure when warranted. Keep discussion private
until a coordinated disclosure decision. Reports may require further evidence
or be found outside the maintained scope; the outcome should be explained.

Repository scanning, passing workflows, or a lack of reported vulnerabilities
does not establish that the project is secure or that future capital
calculations are correct. Static checks do not run Excel or a calculation
engine. Security reports and calculation-validation evidence serve different
purposes.
