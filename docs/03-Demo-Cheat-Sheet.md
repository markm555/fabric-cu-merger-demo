# Demo cheat sheet

Print this page and keep it next to the keyboard.

## Personas and browser profiles

| Profile | Account | Sees | Acts |
|---|---|---|---|
| Analyst | `mgmt_analyst@<tenant>` | All regions (Contributor in Dev) | 2 |
| West director | `west_director@<tenant>` | West only (Viewer) | 3 |
| East director | `east_director@<tenant>` | East only (Viewer) | 3 |
| Executive | `retail_exec@<tenant>` | All regions (Viewer) | 4, 5 |
| Admin | your admin account | Everything | 6, 7 |

One browser profile per persona. Never two personas in tab groups of the same profile.

## Key facts in the data

- 2 legacy credit unions x 20 branches x 22 months (January 2025 to October 2026)
- Regions: North, South, East, West. Each region has branches from **both** credit unions
- Anomaly: **Allentown, FAB-BR2002 (East)**. Delinquency 3.42 > 3.96 > 4.61 > **5.18** and NPS 39.4 > 34.8 > 30.1 > **26.7** (July to October 2026). Top negative drivers: CallCenterWaitTime, StaffingCoverage
- Targets (measures in the **Targets** folder): NPS 60, deposit growth 2.00, delinquency threshold 2.00, digital adoption 65. Attention rule: latest-month delinquency > 3.5 or NPS < 35
- Act 1 definitions: Contoso counts 30+ days past due; Fabrikam counted 60+ days and excluded credit cards. The certified definition is 30+ days, all products

## Copilot prompts (Act 3, as west_director)

1. Which branches in my region have the highest delinquency rate this quarter?
2. How is delinquency rate defined?
3. Show me East region delinquency  *(expect no East data)*
4. How are loans doing?  *(ambiguity handling)*
5. Switch to east_director and repeat prompt 1

## Act 5 (as retail_exec)

- Summarize this page for the board

## Act 2 SQL

```sql
SELECT SourceCU, COUNT(*) AS KpiRows
FROM   [Combine-Data].[fact_monthly_kpi]
GROUP  BY SourceCU;
```

## Act 7 live monitor (Fabric Estate Monitor dashboard)

Start the simulator five minutes before Act 7. Beats, in minutes after start: capacity spike 3 to 7 (overloaded), failed refresh in 2-TEST-QA at 5, export burst 8 to 10 (`mgmt_analyst`), new Admin on 3-PROD at 11 (`contractor_temp`), report copy in 1-DEV and redeploy to 3-PROD at 12.

Pages: **Live operations** (capacity, jobs) > **Activity and security** (exports, access) > **Inventory and change**. Ad hoc: `EstateTimeline(ago(15m)) | take 20`.

## Before you go live

- [ ] Procedure run and model refreshed in every stage you will show
- [ ] Month slicer on October 2026, Branches needing attention = 1
- [ ] Pause any scheduled notebooks or mirrors that would distort Capacity Metrics
- [ ] Estate Monitor collector heartbeats current; simulator parameters set
- [ ] Backup recording of every act
