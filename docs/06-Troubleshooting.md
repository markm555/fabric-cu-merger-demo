# Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| A director sees other regions | The account is Member, Contributor or Admin, or isn't in the **Security Scope** role | Make directors **Viewers** and add them to the role. Check with **Test as role** |
| A director sees another director's region in one browser tab | Two personas signed in to the same browser profile (tab groups share the session) | Use **one browser profile per persona**. Sign out and close the profile, then sign in again |
| Everyone sees nothing after RLS | UPNs in `security_user_scope` don't match sign-in names (wrong `TENANT_DOMAIN`, or `{tenant}` left in) | Run `SELECT * FROM [Combine-Data].[security_user_scope]`. Fix the domain, rerun the notebook and procedure, refresh the model |
| `Invalid object name 'Contoso_CU.dbo.dim_branch'` in the procedure | Lakehouse in another workspace, a different name, or the SQL endpoint hasn't synced yet | Keep sources and warehouse in one workspace with the exact names. In the lakehouse's SQL analytics endpoint select **Refresh**, then rerun |
| Notebook fails reading from GitHub | Private repo, wrong `REPO_RAW_BASE`, or no outbound internet | Check the URL in a browser, or use `DATA_SOURCE = "files"` |
| Power BI Desktop asks for the server on open | The `SqlEndpoint` parameter still says `REPLACE-ME` | **Transform data > Edit parameters** |
| Refresh in the service fails with a credentials error | Data source credentials not set after publish or deploy | Semantic model **Settings > Data source credentials > OAuth2** |
| Each pipeline stage shows the same data | The parameter rule isn't set, so Test and Prod read Dev's warehouse | Add a parameter rule for `SqlEndpoint` in each stage and redeploy |
| Copilot button is missing | Capacity below F2 or trial, tenant setting off, or the user lacks access | Use a paid F SKU and turn on the Copilot tenant setting for the demo users |
| Copilot answers differ from rehearsal | Copilot wording varies run to run | Rehearse the exact prompts, keep the model's measure descriptions, and keep a recording |
| Branches needing attention isn't 1 | Month slicer isn't October 2026, or the targets were edited | Set Month to October 2026; check the **Targets** measures |
| Viewers can't open the report on a small capacity | Below F64, viewers need Pro or PPU | Assign Pro licenses or use a larger capacity |
| Estate Monitor dashboard is empty | No events yet, wrong data source, or the eventstream destination isn't published | Run `RawEvents \| summarize count() by type` in the KQL database. If empty, check the eventstream is published and its destination uses table `RawEvents` with mapping `RawEvents_mapping`. If not empty, open the dashboard's **Data sources** and select the EstateMonitor database |
| Collector reports HTTP 401 or 403 | The identity isn't a Fabric administrator, or the service principal isn't allowed to use read-only admin APIs | Run as a Fabric admin, or enable the tenant setting for service principals and add the app's security group |
| Collector reports HTTP 429 | Admin API rate limits | Raise the minutes in `COLLECT_EVERY_MIN` (activity log especially) |
| Activity shows up late | Activity-log entries reach the API after a delay | Expected. Native job and capacity events are near real time; use the simulator for a timed story |
| No capacity or job events | Missing capacity admin rights, the eventstream is in another region, or the source is scoped to other items | Check the Fabric event sources in the eventstream and Real-Time hub's paused event configurations |
| Dashboard shows "Error loading dashboard" after import | The data source points at a database that doesn't exist in your tenant | Rerun `Estate_Monitor_Setup` (it binds the data source), or edit the data source in the dashboard |
| Simulated data mixed with real data | The simulator was left running | Stop it, filter with `IsSimulated == false`, or delete simulator rows (doc 07) |
| Installer: "No SQL Server ODBC driver in this runtime" | The Spark runtime has no ODBC driver | The installer skips the SQL step and carries on. Run the three `sql/warehouse` scripts in the warehouse query editor, then rerun the installer to refresh the model |
| Installer: RLS members FAILED | XMLA read-write is off on the capacity, or the persona account doesn't exist | Turn on XMLA read-write (Capacity settings > Power BI workloads), or add members under semantic model > Security |
| Installer: credentials or refresh FAILED | The data source token wasn't accepted | Semantic model > Settings > Data source credentials > Edit > OAuth2, sign in, then refresh |
| Installer: eventstream FAILED | The eventstream definition API changed or isn't enabled in your region | The collector falls back to writing directly to the eventhouse. Create the eventstream by hand (doc 07, step 3) if you want it in the demo |
