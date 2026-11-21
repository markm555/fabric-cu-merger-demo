# Governance and operations (Act 7)

## Fabric_Governance notebook

`notebooks/Fabric_Governance.ipynb` produces tenant-wide inventory and clean-up data:

| Section | What it does | Writes? |
|---|---|---|
| 1. Inventory | All workspaces and items through the Fabric admin APIs | Delta tables only |
| 2. Stale scoring | Items with no use **and** no change in `STALE_DAYS` (default 90) | Delta tables only |
| 3. Orphan report | Workspaces with no admin, and item creators to match against departed users | Delta tables only |
| 4. Archive and delete | Exports item definitions (and a PBIX for reports), then optionally deletes | **Yes, manual only** |
| 5. Ownership | Takes over semantic models and paginated reports, adds workspace admins | **Yes, manual only** |

How to run it:
1. Import it into an admin workspace and attach a default lakehouse.
2. Run it as a **Fabric administrator**. Scheduled runs execute as the notebook owner.
3. Sections 1 to 3 are read-only and safe to schedule weekly.
4. Sections 4 and 5 run only when `RUN_ACTIONS = True` **and** you list item IDs explicitly. Nothing is archived, deleted or taken over automatically.

**Activity history.** Stale scoring reads an activity table (`ACTIVITY_TABLE`, default `activity_events`). `Estate_Monitor_Collector.ipynb` fills it from the activity events API as part of the Real-Time Estate Monitor ([doc 07](07-Real-Time-Estate-Monitor.md)); attach the same lakehouse to both notebooks. Until the table exists, the notebook falls back to the built-in 30-day *unused artifacts* API and marks confidence as Low. Confidence moves to High once the table holds `STALE_DAYS` of history, so start the collector early.

## Preparing Act 7

**A slow visual.** On a copy of the Executive Scorecard page, add a table visual with BranchName, Driver and MonthStart and this measure (don't add it to the certified model):

```dax
Slow Measure (demo only) =
SUMX (
    CROSSJOIN (
        VALUES ( 'Combine-Data dim_branch'[BranchName] ),
        VALUES ( 'Combine-Data fact_driver_breakdown'[Driver] ),
        VALUES ( 'Combine-Data dim_month'[MonthStart] )
    ),
    CALCULATE ( RANKX ( ALL ( 'Combine-Data fact_driver_breakdown' ), [Driver Impact] ) )
)
```

Record its Performance analyzer timing in rehearsal so you know what to expect, then compare it with the Executive Scorecard's timing.

**A refresh failure.** The day before, set the semantic model's **WarehouseName** parameter in a test copy to a name that doesn't exist and run a refresh. The Monitoring hub then shows a failed refresh with a clear error. Set it back afterwards.

**Capacity Metrics.** Install the **Microsoft Fabric Capacity Metrics** app and let it collect data for a day. A few back-to-back refreshes or the slow visual give you a visible spike.

**Admin monitoring.** Turn on the admin monitoring workspace in the admin portal for built-in feature usage and inventory reports.

**Real-Time Estate Monitor.** Set it up a few days ahead so the inventory baseline and activity history exist, add the Activator alerts, and rehearse with the simulator. See [doc 07](07-Real-Time-Estate-Monitor.md).

**Between rehearsals.** Pause scheduled notebooks, mirrors and frequent refreshes so they don't distort the capacity picture.

## Sample admin and ops data

Each legacy lakehouse also holds three tables you can use for an inventory or capacity story without touching a real tenant:

| Table | Contents |
|---|---|
| `admin_inventory_artifacts` | 175 to 180 fictitious items with owner, last viewed date, certification, size and license tier |
| `ops_refresh_history` | 117 refreshes with status, duration and error category |
| `ops_capacity_metrics_5min` | Three days (October 20 to 23, 2026) of five-minute CPU, memory, query wait and throttling samples for two capacities |

They aren't in the semantic model. Build a quick report over them if you need one.
