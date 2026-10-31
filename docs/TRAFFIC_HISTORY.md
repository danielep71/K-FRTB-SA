# 📈 Repository traffic history

[![Purpose: analytics](https://img.shields.io/badge/purpose-analytics-1D76DB)](../README.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](../LICENSE)

## 🎯 What is collected

The dedicated [traffic-history branch](https://github.com/danielep71/K-FRTB-SA/tree/traffic-history)
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
  universal repository-integrity gate (#7, completed).
- The export job receives `contents: write` through its built-in
  `GITHUB_TOKEN` only to publish the data branch. A short-lived GitHub App installation token
  reads the traffic endpoints in a separate curl-only step. The Python merge
  and publication step never receives the App token or private key. Checkout credentials are not persisted.
- All source/data responses validate before Git writes. A single commit
  contains CSV, latest payload, and snapshot. Ref updates are non-forced;
  competing history updates fail rather than overwrite another commit.
- Protect `traffic-history` against deletion and force pushes without requiring
  PRs for its ordinary automated data commits. Do not execute workflow code
  from the data branch.

## 🔑 GitHub App configuration

I configure the App and credentials before approving the migration merge:

1. Create a dedicated traffic GitHub App, disable its webhook and grant only
   **Administration: Read-only** (GitHub adds Metadata: Read-only).
2. Install it on this repository. Generate a dedicated private key.
3. Keep the `analytics` environment restricted to `main`. Add the App Client ID
   as variable **TRAFFIC_APP_CLIENT_ID** and the complete PEM key as secret
   **TRAFFIC_APP_PRIVATE_KEY** in that environment, not at repository scope.
4. Confirm configuration before merging the migration. After integration into
   the default branch, dispatch **Export repository traffic** on `main` and
   verify a successful run and a new `traffic-history` commit.
5. Only after that successful run, I delete the old `TRAFFIC_TOKEN` environment
   secret and revoke the personal token. There is no fallback to that token.

Never put the private key in source, logs, issues, screenshots or chat.
The configuration check sees only whether the key exists. Only the pinned
App-token action receives its value; only the curl API step receives the
installation token. The action scopes the token to this repository with
Administration: read, expires it after an hour and revokes it at job end.
Publication retains the built-in `GITHUB_TOKEN` with contents: write.

### Key rotation

Generate a new dedicated key, replace the `analytics` environment secret,
then dispatch on main and verify the resulting history commit. Only after
success, delete the old key in the App settings, checking its fingerprint.
Rotate promptly after suspected exposure. Missed data outside GitHub's
14-day window cannot be recovered.

### Failure diagnosis

| Failure | Recovery |
| --- | --- |
| App client ID or private key not set | Configure both values in `analytics`; check environment access. |
| App token creation fails | Verify Client ID, key and installation on this repository. |
| curl HTTP 401 | Check installation and key, then rerun. |
| curl HTTP 403/404 | Verify Administration: read and repository selection; accept permission changes. |
| curl HTTP 429/5xx or timeout | Retry later; curl retries transient errors before failing. |
| Missing, malformed or oversized response | Inspect the failing endpoint; no history is published. |
| Invalid CSV or missing data branch | Restore valid history; never reset existing history. |
| Publication rejected or non-fast-forward | Check branch rules and competing updates, then rerun; never force. |

## 🧪 Validation and operations

Python 3.12 on the workflow runner uses only the standard library. These
tooling requirements do not choose the engine platform.

```sh
python3 -m unittest discover -s tests/tooling -p test_traffic_history.py -v
```

Tests cover overlapping windows, preservation of old days, empty windows,
invalid counts/dates, duplicate samples, atomic publication, non-forced race
failure, and rejection of privileged execution outside main or without the
response directory, and isolation of App credentials between workflow steps.

After credential configuration and main integration, open Actions →
**Export repository traffic** → **Run workflow**, select main and run it.
Verify the successful run summary and the resulting history commit. Inspect
failure logs for missing/expired permissions, absent branch, malformed data,
or concurrent updates. An existing zero-byte CSV is corrupt and fails header
validation before any Git write; restore valid history rather than treating
it as a new collection. Re-run after fixing the cause; never reset the branch
to make a failed publish pass. No automated issue or external message is sent.

This is operational analytics. Static tests, traffic counts, and successful
collection do not run Excel or validate capital calculations.

## 📋 Live configuration record

Verified on October 18, 2026 (Europe/Rome): the data-only branch exists;
[Protect traffic history](https://github.com/danielep71/K-FRTB-SA/rules/25321321)
is active for its exact ref, blocks deletion and non-fast-forward updates,
and has no bypass actors. The `analytics` environment permits the main branch
only (one branch, zero tags) and holds the `TRAFFIC_TOKEN` environment
secret. The first real export succeeded in
[run 39105087826](https://github.com/danielep71/K-FRTB-SA/actions/runs/39105087826)
and published data commit `af6a68a` on `traffic-history`; issue #23 is closed.
This dated record describes the former personal-token setup. The App migration
requires a separate successful run before its operation is confirmed.
