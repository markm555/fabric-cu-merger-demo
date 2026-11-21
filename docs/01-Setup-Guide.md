# Setup guide

This guide builds the full demo in one Fabric workspace, then optionally extends it to Dev, Test and Prod with Git and a deployment pipeline. Plan about 45 minutes for the core build and another 30 for the optional pieces.

## Fastest path: the one-click installer

`notebooks/Deploy_CU_Merger_Demo.ipynb` does sections 2 to 6, 8 and 9 for you. It's safe to rerun.

1. Push the kit to a public GitHub repo. If it can't be public, upload the whole kit folder to a lakehouse instead.
2. Create the persona accounts in Entra ID (section 6).
3. Create an admin workspace, for example **0-MONITOR**, on your Fabric capacity. Import the notebook there.
4. Set `TENANT_DOMAIN` and `REPO_RAW_ROOT`, and choose `BUILD_STAGES`: `["Dev"]`, or all three for the pipeline story.
5. Select **Run all**. Allow about 20 to 30 minutes per stage.

The notebook creates the workspaces, lakehouses and data, and the **Combined-Data** warehouse with its load and validation. It deploys the semantic model and report bound to that stage's warehouse, sets credentials and refreshes. It grants persona access and adds the **Security Scope** RLS members. It can create the deployment pipeline. It also builds the full Estate Monitor in the admin workspace: lakehouse, eventhouse, views, dashboard, eventstream, scheduled collector, simulator and `Fabric_Governance`.

It ends with a summary table and a short list of what's still manual:
- Fabric event sources on the eventstream
- A one-time OAuth2 sign-in on each model so scheduled refresh keeps working
- Copilot tenant settings
- The app
- Alerts

Run it as a Fabric administrator who is also capacity admin. The sections below are the manual path, and what to check if a step in the installer fails.

## Build order at a glance

| Step | What you build | Where | Time | Needed for |
|---|---|---|---|---|
| 3 | Three lakehouses loaded by `Load_Source_Data` | 1-DEV | 10 min | All acts |
| 4 | **Combined-Data** warehouse and `usp_Load_Combined` | 1-DEV | 10 min | All acts |
| 5 to 6 | Semantic model, report, RLS personas | 1-DEV | 15 min | Acts 2 to 5 |
| 7 to 8 | App, Git and Dev / Test / Prod pipeline | 1-DEV to 3-PROD | 30 min | Act 2 (optional) |
| 9 | Real-Time Estate Monitor (eventhouse, eventstream, collector, dashboard) | 0-MONITOR | 30 min | Acts 6 and 7 (optional) |
| doc 05 | `Fabric_Governance` notebook and Act 7 assets | 0-MONITOR | 15 min | Act 7 |

## 1. Prerequisites

| Need | Why | Notes |
|---|---|---|
| Fabric capacity, **F2 or larger** (paid) | Copilot in Power BI does not run on trial capacity | Below F64, every report viewer needs a Power BI Pro or PPU license |
| Workspace Admin on the demo workspace(s) | Create items, manage access and RLS | |
| Power BI Desktop (current release) | Open the `.pbip` project | If your version still lists them under **File > Options > Preview features**, turn on *Power BI Project (.pbip) save option*, *Store semantic model using TMDL format* and *Store reports using enhanced metadata format (PBIR)* |
| Tenant settings (Fabric admin portal) | | *Users can use Copilot and other features powered by Azure OpenAI* on for the demo users. If your capacity is outside the US or EU, also allow data to be processed and stored outside your geography |
| Demo user accounts (Entra ID) | One per persona, see section 6 | Use a demo tenant, never real customer accounts |

Optional pieces need more: Git integration needs a GitHub or Azure DevOps repo, Act 6 needs Purview and Sentinel, the mirroring variant needs two Azure SQL databases, and the Real-Time Estate Monitor needs a Fabric administrator and capacity admin (doc 07).

## 2. Create the workspace

1. Create a workspace, for example **1-DEV**, and assign it to your Fabric capacity.
2. If you will use a deployment pipeline later, also create **2-TEST-QA** and **3-PROD**. Leave them empty for now.

## 3. Load the source data

1. Push this repository to your own GitHub account (public, or use the `files` option below).
2. In the workspace select **Import > Notebook > From this computer** and import `notebooks/Load_Source_Data.ipynb`.
3. In the first code cell set:
   - `TENANT_DOMAIN` to your tenant domain, for example `contoso.onmicrosoft.com`
   - `REPO_RAW_BASE` to `https://raw.githubusercontent.com/<you>/<repo>/main/data`
4. Select **Run all**. The notebook:
   - creates the lakehouses **Contoso_CU**, **Fabrikam_CU** and **Enterprise_Ref** if they do not exist
   - loads ten tables into each legacy lakehouse and two into Enterprise_Ref, using explicit schemas
   - replaces `{tenant}` in the RLS scope with your domain
   - refreshes each SQL analytics endpoint so the tables are queryable immediately

**Private repo or no internet access?** Upload the repo's `data` folder to `Enterprise_Ref > Files > data` (keep the three subfolders) and set `DATA_SOURCE = "files"`.

## 4. Build the Combined-Data warehouse

1. In the same workspace create a **Warehouse** named exactly **Combined-Data**.
2. Open a new SQL query and run, in order:
   1. `sql/warehouse/01_create_schema_and_tables.sql` (first time only; it drops and recreates the tables)
   2. `sql/warehouse/02_usp_Load_Combined.sql`
   3. `EXEC [Combine-Data].[usp_Load_Combined];`
   4. `sql/warehouse/03_validation_queries.sql`
3. Check the validation results:
   - 440 KPI rows (20 branches x 22 months) and 20 branches for each of **Contoso CU** and **Fabrikam CU**
   - Regions are exactly **East, North, South, West**
   - **Allentown (FAB-BR2002)** tops the latest-month delinquency list. That is the planted anomaly for Act 4.
   - The RLS table shows your tenant domain, with no `{tenant}` left

The procedure reads the lakehouses with three-part names (`[Contoso_CU].[dbo].[dim_branch]`), so the lakehouses and the warehouse must be in the same workspace.

## 5. Publish the semantic model and report

1. Open `pbip/Monthly Member Intelligence Hub.pbip` in Power BI Desktop. Cancel the first refresh prompt if one appears.
2. Select **Transform data > Edit parameters** and set:
   - **SqlEndpoint**: the warehouse SQL connection string (Warehouse > **Settings > SQL connection string**), for example `xxxx.datawarehouse.fabric.microsoft.com`
   - **WarehouseName**: `Combined-Data`
3. Select **Apply changes**, sign in with your organizational account when prompted, and refresh.
4. **Publish** to the workspace. Optionally apply `themes/ContosoCU-Demo.json` (it is already embedded in the report).
5. In the service open the semantic model **Settings**:
   - **Data source credentials**: OAuth2, signed in as an account that can read the warehouse
   - **Scheduled refresh**: optional
   - **Endorsement**: **Certified** if your admin allows it (otherwise **Promoted**)
   - **Q&A** on, and use **Prep data for AI** / **Approved for Copilot** if your tenant shows them

**Using Git instead of Desktop:** connect the workspace to your repo (**Workspace settings > Git integration**), point it at the `pbip` folder, and select **Update all**. Then set the parameters in the semantic model settings and the credentials as above.

## 6. Personas, access and row-level security

Create these accounts in your demo tenant. The notebook already loaded them into the RLS table with your domain.

| Persona | UPN prefix | Workspace role | RLS region | Used in |
|---|---|---|---|---|
| Management analyst | `mgmt_analyst` | Contributor (Dev) | ALL | Act 2 |
| West regional director | `west_director` | **Viewer** | West | Act 3 (lead) |
| East regional director | `east_director` | **Viewer** | East | Act 3 (comparison) |
| North and South directors | `north_director`, `south_director` | **Viewer** | North, South | Backups |
| Retail banking executive | `retail_exec` | **Viewer** | ALL | Acts 4 and 5 |
| Fabric administrator | your admin account | Admin + Fabric admin role | n/a | Acts 6 and 7 |

Then:

1. Semantic model **> Security > Security Scope**: add every persona above, or an Entra group that contains them. Role membership is **not** deployed by pipelines or Git, so repeat this in every stage.
2. Use **Test as role** with a director's account to confirm only that region appears.
3. **Directors must be Viewers.** Members, Contributors and Admins bypass RLS.
4. To change who sees what, edit `data/enterprise_ref/security_user_scope.csv` (or the Enterprise_Ref table), rerun the procedure and refresh the model.

## 7. Publish an app (optional)

Create an **org app** (or a workspace app) that contains the report, and give access to the director and executive personas. For an org app the report changes show up immediately. For a workspace app, select **Update app** after each change.

## 8. Dev, Test and Prod (optional, for Act 2)

1. Connect **1-DEV** to Git (step 5) so the semantic model's TMDL is in version control.
2. Create a **deployment pipeline** with stages 1-DEV, 2-TEST-QA and 3-PROD.
3. Each stage needs its own data: run the notebook and the warehouse scripts in 2-TEST-QA and 3-PROD too. Leave the warehouse out of pipeline deployments.
4. Add a **parameter rule** on the semantic model in Test and Prod so `SqlEndpoint` points at that stage's warehouse.
5. Deploy Dev to Test to Prod, set credentials and RLS membership in each stage, and certify the Prod model.
6. Before the demo, stage a small change in Dev (for example edit a measure description) so **Compare** shows a real difference.

## 9. Real-Time Estate Monitor (optional, for Acts 6 and 7)

The Estate Monitor gives Act 7 a live view of the whole tenant: capacity and throttling, jobs and refreshes, views, exports and Copilot use, access changes and a full item inventory. It also feeds the activity history that `Fabric_Governance` uses for stale scoring. Plan about 30 minutes. Full details, the architecture and alert setup are in [doc 07](07-Real-Time-Estate-Monitor.md).

1. **Workspace.** Create an admin workspace, for example **0-MONITOR**, on a paid capacity, with a lakehouse named **Monitor_LH**. Keep it out of the deployment pipeline.
2. **Eventhouse and dashboard.** Import `notebooks/Estate_Monitor_Setup.ipynb`, set `REPO_RAW_ROOT` (or `SOURCE = "files"`), and **Run all**. It creates the **EstateMonitor** eventhouse, the `RawEvents` table and mapping, the KQL views and the **Fabric Estate Monitor** dashboard.
3. **Eventstream.** Create **EstateMonitor_ES** with:
   - a **Custom endpoint** source named `collector` (copy its connection string, ideally into Key Vault)
   - **Fabric events** sources: Job events, Workspace item events (by workspace: 1-DEV, 2-TEST-QA, 3-PROD), Capacity overview events and Capacity operation events
   - an **Eventhouse** destination: EstateMonitor database, existing table `RawEvents`, JSON, mapping `RawEvents_mapping`

   Then **Publish**. The eventstream must be in the same region as the capacity.
4. **Collector.** Import `notebooks/Estate_Monitor_Collector.ipynb`, attach **Monitor_LH**, and run once with `SINK = "dryrun"`. Then set `SINK = "eventstream"` plus the connection string (or Key Vault settings), run again for the baseline, and **schedule it hourly** with `RUN_MINUTES = 55`.
5. **Governance link.** Attach **Monitor_LH** to `Fabric_Governance.ipynb` and leave `ACTIVITY_TABLE = "activity_events"`. Start the collector at least a few weeks before the demo if you want stale scoring at High confidence (it needs `STALE_DAYS` of history).
6. **Simulator (demo day).** Import `notebooks/Estate_Monitor_Simulator.ipynb` and start it about five minutes before Act 7. Its events are labelled `IsSimulated` and can be deleted afterwards (doc 07).
7. **Alerts (optional).** Create Activator alerts for failed refreshes, an overloaded capacity, export bursts and new workspace admins, sent to a Teams chat.

Rights needed: **Fabric administrator** for the collector, **capacity admin** for capacity events, and read access to the workspaces you subscribe to.

## 10. Rehearsal checklist

- [ ] `EXEC [Combine-Data].[usp_Load_Combined]` run and the model refreshed in every stage you will show
- [ ] The **Legacy credit union** slicer shows Contoso CU and Fabrikam CU
- [ ] The **Month** slicer set to October 2026, and Allentown shows red with **Branches needing attention = 1**
- [ ] RLS tested with Test as role and with real director sign-ins
- [ ] **One browser profile per persona** (see Troubleshooting: shared sign-ins leak data between tabs)
- [ ] Copilot prompts rehearsed and a backup recording made of every act
- [ ] Act 7 assets ready: a slow visual, a staged refresh failure, the Capacity Metrics app installed (see doc 05)
- [ ] Estate Monitor: collector heartbeats current on the **Collector health** page, and the simulator ready to start five minutes before Act 7 (doc 07)
