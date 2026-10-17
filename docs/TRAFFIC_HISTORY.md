# 📈 Repository traffic history

[![Purpose: analytics](https://img.shields.io/badge/purpose-analytics-1D76DB)](../README.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](../LICENSE)

## 🎯 What is collected

The dedicated [traffic-history branch](https://github.com/danielep71/MKT-FTRB-SA/tree/traffic-history)
holds aggregate views, clones, referring sites, and popular paths returned by
GitHub's traffic API. It is a data branch, never merged into main or the
development release branch. No visitor-level identities are collected.

| File on the data branch | Meaning |
| --- | --- |
| `data/daily.csv` | Latest observed views/clones and daily unique counts for each UTC day |
| `data/latest.json` | Latest successful collection, raw endpoint payloads, collection time and workflow source commit |
| `data/snapshots/YYYY-MM-DD.json` | Latest successful snapshot for that UTC collection date; earlier same-day versions remain in Git history |
| `README.md` and `LICENSE` | Data-branch purpose and MIT terms |

GitHub exposes a rolling traffic window of about 14 days. Daily collection
preserves observations beyond that window; it cannot reconstruct expired
history. Snapshot dates are collection dates; sample timestamps identify
the measured UTC days. Reruns replace each overlapping metric/day rather
than adding totals. Missing sample days preserve prior observations; blank
CSV cells mean unobserved, not zero. Counts can change while GitHub revises
a recent window.

**Daily unique counts must not be summed as distinct people over a longer
period.** The same person may appear on several days. Referrer/path rankings
are rolling-window snapshots and are not added across collection dates.
Analytics describe repository activity, not user adoption or calculation
quality.

## ⚙️ Workflows and trust boundaries

- **Export repository traffic** runs daily at 04:37 UTC and supports manual
  dispatch. Collection runs only on `main`, using the `analytics` environment.
  Default-branch schedules may be delayed or disabled by GitHub after extended
  repository inactivity; inspect Actions rather than assuming collection ran.
- **Validate traffic tooling** runs offline tests on relevant PRs and pushes
  to main and release branches. It receives read-only contents access and no
  traffic credential. It is path-filtered analytics validation, not the
  universal repository-integrity gate tracked in #7.
- The export job receives `contents: write` through its built-in
  `GITHUB_TOKEN` only to publish the data branch. A separate `TRAFFIC_TOKEN`
  reads the traffic endpoints. Checkout credentials are not persisted.
- All source/data responses validate before Git writes. A single commit
  contains CSV, latest payload, and snapshot. Ref updates are non-forced;
  competing history updates fail rather than overwrite another commit.
- Protect `traffic-history` against deletion and force pushes without requiring
  PRs for its ordinary automated data commits. Do not execute workflow code
  from the data branch.

## 🔑 Required credential

Create an `analytics` environment restricted to deployment from `main`.
Its environment secret must be named **TRAFFIC_TOKEN**. Use a fine-grained
token scoped to this repository with **Administration: read**; the token
does not need contents write, issue write, or access to other repositories.
GitHub requires this permission to read traffic. The built-in workflow token
cannot be granted administration access.

Token creation and secret entry are owner-controlled operations. Never put
a token in source, issue comments, command output, screenshots, or chat.
Record its expiry privately and rotate it before expiry. A missing or invalid
credential fails collection with an actionable error; it does not create
zero-valued substitute data.

[GitHub traffic API requirements](https://docs.github.com/en/rest/metrics/traffic)
define the current access and data contract. This repository had no secrets
at initial inspection on October 18, 2026 (Europe/Rome). Issue #23 records
credential and first-run readiness; this document does not claim collection
has succeeded before a real run exists.

## 🧪 Validation and operations

Python 3.12 on the workflow runner uses only the standard library. These
tooling requirements do not choose the engine platform.

```sh
python3 -m unittest discover -s tests/tooling -p test_traffic_history.py -v
```

Tests cover overlapping windows, preservation of old days, empty windows,
invalid counts/dates, duplicate samples, atomic publication, non-forced race
failure, and rejection of privileged execution outside main or without the
credential.

After credential configuration and main integration, open Actions →
**Export repository traffic** → **Run workflow**, select main and run it.
Verify the successful run summary and the resulting history commit. Inspect
failure logs for missing/expired permissions, absent branch, malformed data,
or concurrent updates. Re-run after fixing the cause; never reset the branch
to make a failed publish pass. No automated issue or external message is sent.

This is operational analytics. Static tests, traffic counts, and successful
collection do not run Excel or validate capital calculations.

## 📋 Live configuration record

Verified on October 18, 2026 (Europe/Rome): the data-only branch exists;
[Protect traffic history](https://github.com/danielep71/MKT-FTRB-SA/rules/25321321)
is active for its exact ref, blocks deletion and non-fast-forward updates,
and has no bypass actors. The `analytics` environment permits the main branch
only (one branch, zero tags). Its TRAFFIC_TOKEN secret is not configured yet;
issue #23 remains open for the credential and first real export.
