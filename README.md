# 📈 FRTB-SA traffic history

This branch stores generated aggregate repository analytics only. It is never
merged into main or a release branch, and its history is not rewritten.

- `data/daily.csv`: views and clones per UTC day, with the collection that
  last changed each pair.
- `data/snapshots.csv`: one row per collection day, with the 14-day totals and
  the repository's stars, forks, watchers and open issues.
- `data/referrers.csv` and `data/paths.csv`: the top referrers and paths of
  each collection day.
- `data/badges/*.json`: the README badges.
- `data/legacy/`: the files of the former layout, kept as an archive; they
  were replayed into the CSV files on 2026-10-31.

Overlapping windows replace observations rather than add them. Daily unique
counts are not unique people across longer periods. No visitor-level
identities are collected.

[Operations, merge rules and credentials](https://github.com/danielep71/K-FRTB-SA/blob/main/docs/TRAFFIC_HISTORY.md).

Data and project material use the [MIT License](LICENSE).
