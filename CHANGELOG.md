# Changelog

## 2026-11-21: One-click installer

- Added `notebooks/Deploy_CU_Merger_Demo.ipynb`, which builds the whole demo from a Fabric notebook:
  - workspaces, lakehouses and data
  - the Combined-Data warehouse and its load
  - the semantic model and report, with credentials and a refresh
  - persona access and RLS members
  - an optional deployment pipeline
  - the full Real-Time Estate Monitor
- Setup guide, README and troubleshooting updated.
- Not yet tested in a tenant.

## 2026-11-21: Estate Monitor merged into the main kit

- Added the **Real-Time Estate Monitor** for Acts 6 and 7: the notebooks `Estate_Monitor_Setup`, `Estate_Monitor_Collector` and `Estate_Monitor_Simulator`, the `kql/` scripts (the `RawEvents` table and mapping, and the Estate* views), and the four-page **Fabric Estate Monitor** Real-Time Dashboard in `dashboards/`.
- It replaces the account-specific inventory and activity notebook from the original demo.
- `Fabric_Governance` now reads the `activity_events` table that the collector writes.
- Docs updated:
  - setup guide: build-order table and an expanded section 9
  - demo script: Act 7 live-monitor beats
  - cheat sheet: simulator timeline
  - governance doc: link to the activity history
  - troubleshooting: Estate Monitor issues
  - new doc 07
- The data, SQL, PBIP model and report are unchanged.

## 2026-11-18: Generic kit

- Sanitized Contoso CU and Fabrikam CU kit:
  - loader notebook with explicit schemas
  - Combined-Data warehouse
  - parameterized PBIP
  - governance notebook
  - docs 01 to 06
