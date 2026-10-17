# 📈 FRTB-SA traffic history

This branch stores generated aggregate repository analytics only. It is never
merged into main or the development release branch.

- `data/daily.csv`: latest observed counts per UTC day; blanks mean unobserved.
- `data/latest.json`: latest successful collection (present after the first run).
- `data/snapshots/YYYY-MM-DD.json`: latest snapshot for each collection date.

Overlapping windows replace observations rather than add them. Daily unique
counts are not unique people across longer periods. Earlier same-day samples
remain available in Git history. No visitor-level identities are collected.

[Operations and credential readiness](https://github.com/danielep71/MKT-FTRB-SA/blob/main/docs/TRAFFIC_HISTORY.md)
are tracked in [issue #23](https://github.com/danielep71/MKT-FTRB-SA/issues/23).
The initial CSV contains a header only; it is not evidence of a collection.

Data and project material use the [MIT License](LICENSE).
