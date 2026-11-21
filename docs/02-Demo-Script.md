# Demo script and talk track

A click-by-click script for a two-hour session. It follows one business thread end to end: **loan and member risk reporting across the newly combined credit union** (legacy Contoso CU plus legacy Fabrikam CU), seen through the **Monthly Member Intelligence Hub**. Each act lists the persona, setup, clicks, talk track, the capability it proves and the handoff.

**North Star:** one governed single source of truth, with trusted KPIs that mean the same thing across the combined organization, that any employee can question in natural language, with governance that fits a merged, regulated institution.

Adjust the timings and presenters to your team. Acts 1 to 5 and 7 run entirely in this repo's environment. Act 6 needs Purview and Sentinel, so treat it as optional or show it from a recording.

## Run of show

| Start | Segment | Suggested presenter | Capability shown |
|---|---|---|---|
| 0:00 | Welcome, agenda, introductions (5 min) | Account lead | |
| 0:05 | Act 1: The Problem (5 min) | Account lead | Metric standardization across legacy organizations |
| 0:10 | Act 2: The Foundation (20 min) | Data platform presenter | Combined sources, certified semantic model, lineage, version-controlled change management, Dev/Test/Prod |
| 0:30 | Act 3: Ask, Don't Build (20 min) | Data platform presenter | Natural-language Q&A with grounded answers, traceability, row-level security |
| 0:50 | Act 4: Spot It, Explain It, Review It (10 min) | Data platform presenter | Anomaly explanation with human review |
| 1:00 | Act 5: It Rolls Up, Trusted (15 min) | Data platform presenter | Executive scorecard, cascading reporting, consistent results |
| 1:15 | Act 6: Prove It's Safe (15 min, optional) | Security presenter | Auditing, AI controls, DLP, SIEM, agent governance |
| 1:30 | Act 7: Run It at Scale (15 min) | Data platform presenter | Performance, refresh and capacity diagnostics, live estate monitoring, inventory, licensing |
| 1:45 | Recap and Q&A (15 min) | Account lead + all | |

## Demo environment

| Item | Name | Notes |
|---|---|---|
| Workspaces (deployment pipeline) | 1-DEV, 2-TEST-QA, 3-PROD | Promote with parameter rules so each stage reads its own warehouse |
| Legacy Contoso source | Contoso_CU (lakehouse or mirrored database) | See doc 04 for the mirrored and Snowflake variants |
| Legacy Fabrikam source | Fabrikam_CU (lakehouse or mirrored database) | |
| Enterprise reference | Enterprise_Ref (lakehouse) | Certified glossary and RLS scope |
| Combined warehouse | Combined-Data, schema Combine-Data | Loaded by `EXEC [Combine-Data].[usp_Load_Combined]`; `SourceCU` shows Contoso CU and Fabrikam CU |
| Semantic model and report | Monthly Member Intelligence Hub | Executive Scorecard page, Driver Analysis drill-through, Security Scope RLS role by region |
| Source control | Your GitHub repo, `pbip` folder | 1-DEV synced to `main` |
| Platform apps | Fabric Capacity Metrics, admin monitoring workspace | Act 7 |
| Real-Time Estate Monitor | 0-MONITOR workspace: EstateMonitor eventhouse, EstateMonitor_ES eventstream, Fabric Estate Monitor dashboard | Acts 6 and 7 (doc 07) |

Personas and their access are in the [setup guide](01-Setup-Guide.md#6-personas-access-and-row-level-security).

---

## Act 1: The Problem

**Setup.** One slide: legacy Contoso CU and legacy Fabrikam CU side by side, each with its own definition of the same KPI, plus the North Star sentence. The sample data already holds two different definitions of delinquency:

| | Legacy Contoso CU | Legacy Fabrikam CU |
|---|---|---|
| Delinquency rate | Percent of loans 30+ days past due | Share of loan balances **60+** days past due, **excluding credit cards** |

(Source: `glossary_kpi_definitions` in each legacy lakehouse.)

**Click path**

| # | Click or action | What the audience sees |
|---|---|---|
| 1 | Show the side-by-side KPI slide | Two definitions, two numbers, one organization |
| 2 | Show the North Star slide | The success criteria in one sentence |

**Talk track**
- "Contoso and Fabrikam are one organization now, but the data still speaks two languages. The same risk metric means one thing on the legacy Contoso side and something else on the legacy Fabrikam side."
- "For a regulated institution that is a board-reporting risk, not an inconvenience. Today we'll follow one story from the source systems all the way to the board, the way your people would actually experience it."

**Capability shown:** metric standardization across legacy organizations.
**Handoff:** "Let's start where trust starts: the data foundation."

---

## Act 2: The Foundation

**Persona:** management analyst (`mgmt_analyst`). **Products:** OneLake, lakehouse or mirroring, Data Warehouse, Power BI, deployment pipelines, Git.
**Setup:** tabs open for the 1-DEV workspace, the Contoso_CU and Fabrikam_CU sources, the Combined-Data query editor, the semantic model, the deployment pipeline, the GitHub repo and the 3-PROD lineage view.

**Click path**

| # | Click or action | What the audience sees |
|---|---|---|
| 1 | Open Contoso_CU and Fabrikam_CU; show the tables (or, with mirroring, replication status and row counts) | Both legacy sources land in OneLake, no ETL pipelines to maintain |
| 2 | Optional: show the Snowflake tile in **New item > Mirrored database** | Snowflake can stay the system of record; Fabric reads from it |
| 3 | Open Combined-Data and run `SELECT SourceCU, COUNT(*) FROM [Combine-Data].[fact_monthly_kpi] GROUP BY SourceCU;` | One combined data set labeled Contoso CU and Fabrikam CU |
| 4 | Open the semantic model; show the **Certified KPIs** display folder and a measure description | One documented definition for every KPI |
| 5 | Show the **Certified** endorsement on the 3-PROD model | Certified once, used everywhere |
| 6 | Open the deployment pipeline; **Compare** Dev to Test | Exactly what changed, before it moves |
| 7 | Show the parameter rule pointing Test at its own warehouse; deploy with a note; open deployment history | Controlled promotion with an audit trail |
| 8 | Open GitHub: the commit history of the TMDL files | Version-controlled, readable, portable definitions |
| 9 | In 3-PROD open **Lineage view**, then **Impact analysis** on the semantic model | Source to definition to report, and who a change would affect |

**Talk track**
- "Your existing platforms stay where they are. Fabric brings both legacy sources into OneLake without building or maintaining ETL pipelines."
- "This is the moment that matters: we define the delinquency rate once, certify it, and it means the same thing for both legacy organizations."
- "Changes to a governed KPI don't go straight to production. They're versioned in Git, compared, promoted through Test with rules, and every deployment is logged with who and why."

**Watch-outs**
- Be accurate about sources. The default build uses lakehouses loaded from CSV; if you show mirroring, say whether the source is SQL or Snowflake.
- If asked about copies: mirroring is managed replication, not ETL; the source stays the system of record.

**Capability shown:** coexistence with existing platforms; lineage from source to semantic definition to report; certified data products with version-controlled change management; Dev, Test and Prod environments; open formats.
**Handoff:** "The foundation is certified. Now let's see what that means for someone who isn't an analyst."

---

## Act 3: Ask, Don't Build

**Persona:** West regional director (`west_director`, Viewer). **Products:** Copilot in Power BI.
**Setup:** a browser profile signed in as `west_director` with the 3-PROD report (or app) open and the Copilot pane closed. A second profile ready as `east_director`.

**Click path**

| # | Click or action | What the audience sees |
|---|---|---|
| 1 | Open Copilot; ask *"Which branches in my region have the highest delinquency rate this quarter?"* | Only West branches, from both legacy credit unions |
| 2 | Expand how Copilot arrived at the answer (measure, definition, query) | Grounded in the certified measure, with source traceability |
| 3 | Ask *"How is delinquency rate defined?"* | The governed description from the model |
| 4 | Ask *"Show me East region delinquency"* | No East data returned; row-level security enforced |
| 5 | Ask something ambiguous: *"How are loans doing?"* | Copilot states its assumption or asks which measure and period |
| 6 | Switch to the `east_director` profile; ask the first question again | Same certified measure, East-only answer |

**Talk track**
- "This director isn't a data analyst and shouldn't have to be. She asks a plain question and gets the same certified number the CFO sees, filtered to her region."
- "Copilot runs as her. The security defined in the model applies to every answer, so AI never becomes a back door to data."
- "And she can always see where the answer came from: which measure, which definition, which data."

**Watch-outs**
- Directors must be **Viewers**. Member, Contributor and Admin bypass RLS.
- RLS filters by region, so the West director sees West branches from **both** legacy organizations (Las Vegas, Henderson, Reno, Sparks, Carson City, Denver, Boulder, Colorado Springs, Salt Lake City, Provo). Use that as a merger point.
- Rehearse the exact prompts; Copilot wording varies from run to run. Keep a recording as backup.

**Capability shown:** natural-language questions with grounded answers and source traceability; role- and row-level security.
**Handoff:** "She has the answer. Next: what happens when something looks wrong?"

---

## Act 4: Spot It, Explain It, Review It

**Persona:** retail banking executive (`retail_exec`). **Products:** Power BI, Copilot in Power BI.
**Setup:** Executive Scorecard, **Month = October 2026**. The planted anomaly is **Allentown (FAB-BR2002, East)**: from July to October 2026 its delinquency climbs from 3.4 to 5.2 and NPS falls from 39 to 27, driven by call-center wait time and staffing coverage.

**Click path**

| # | Click or action | What the audience sees |
|---|---|---|
| 1 | Point to **Branches needing attention = 1** and the red status in the Region to branch scorecard (expand East) | The anomaly surfaces itself |
| 2 | Right-click **Allentown > Drill through > Driver Analysis** | Which drivers help (green) and hurt (red) at that branch |
| 3 | Show the branch-versus-enterprise cards | How far off the enterprise average it is |
| 4 | Back on the scorecard, read the **AI summary** and its "review before sharing" label | Plain-language explanation with a human in the loop |
| 5 | Optional: describe an Activator alert to the director | A notification to a person, not an automated decision |

**Talk track**
- "Here the platform does more than show a number. It spots the branch that's off track, explains which drivers are behind it, and summarizes it in plain language."
- "Nothing is decided automatically. Consequential decisions, especially anything touching credit, stay with people, with the evidence in front of them."

**Watch-outs**
- Don't show an automated loan or exception decision. Most regulated institutions exclude credit-affecting automation without legal and model-risk approval.

**Capability shown:** anomaly and trend identification, metric explanation, summaries with human-review controls.
**Handoff:** "That branch is one line in a much bigger picture. Let's go to the executive view."

---

## Act 5: It Rolls Up, Trusted

**Persona:** retail banking executive (`retail_exec`), all regions visible. **Products:** Power BI, Copilot in Power BI.

**Click path**

| # | Click or action | What the audience sees |
|---|---|---|
| 1 | Show the four KPI cards with targets and status colors | Executive scorecard on certified KPIs |
| 2 | Select **Contoso CU**, then **Fabrikam CU**, in the **Legacy credit union** slicer | Same definitions, comparable results for both organizations |
| 3 | Show the **NPS trend by legacy credit union** line chart | Consistent metric results across the merger |
| 4 | Expand a region in the scorecard matrix down to branches | Cascading management reporting |
| 5 | Show the **Governed KPI definitions** table | The business glossary behind every number |
| 6 | Ask Copilot *"Summarize this page for the board"* | Board-ready narrative grounded in certified KPIs |

**Talk track**
- "The number the West director saw is the same number in the executive's scorecard. Same metric, same definition, no reconciliation."
- "And when the board wants a narrative instead of a chart, Copilot drafts it from the certified data in seconds."

**Watch-outs:** showing the same summary in Teams or Outlook needs a Microsoft 365 tenant; use a recording if your demo tenant has none.

**Capability shown:** executive scorecard on certified KPIs; consistent results across experiences; cascading reporting with drill-through; AI summarization.
**Handoff:** "Everything you just saw touched member data and AI. Let's show how all of it is controlled and audited."

---

## Act 6: Prove It's Safe (optional)

**Persona:** SOC security admin. **Products:** Fabric admin portal, Microsoft Purview, Microsoft Sentinel, Agent 365. Needs those products configured; agree any handoff between tenants in advance.

| # | Click or action | What the audience sees |
|---|---|---|
| 1 | Fabric admin portal: the Copilot setting scoped to a security group, or turned off for a restricted workspace or domain | AI can be disabled by user, workspace or domain |
| 2 | **Fabric Estate Monitor > Activity and security** (or the admin monitoring workspace): who viewed the hub, used Copilot, exported data, changed access, deployed the model | End-to-end activity audit, live |
| 3 | Purview audit and DSPM for AI: the prompts and responses from Act 3 | Prompt and response logging |
| 4 | Attempt an export of labeled member data; show the DLP policy tip or block | Data-exfiltration safeguards |
| 5 | Sentinel: Fabric and Copilot events ingested; open the policy-violation incident | SIEM export and investigation |
| 6 | Agent 365: an agent in the central registry with owner and permissions | Approved agents, centrally governed |

**Talk track**
- "Everything in this demo, the director's question, the drill-through, the summary, is auditable, access-controlled and governed."
- "AI isn't all or nothing. You decide who can use it and on which data, and you can prove what it was asked and what it answered."

**Watch-outs:** hide user names in activity reports or use demo accounts only. Activity data lags by some minutes; stage it the day before.

**Capability shown:** AI governance controls (audit logs, prompt and response retention, disabling features by user, workspace or domain, exfiltration safeguards); auditing and administration.
**Handoff:** "Security is half of running at scale. Let's close with how the platform team keeps it healthy and lean."

---

## Act 7: Run It at Scale

**Persona:** Fabric administrator. **Products:** Performance analyzer, Monitoring hub, Capacity Metrics, Real-Time Estate Monitor (Eventstream, Eventhouse, Real-Time Dashboard, Activator), admin monitoring, `Fabric_Governance` notebook. Preparation is in [doc 05](05-Governance-and-Operations.md) and [doc 07](07-Real-Time-Estate-Monitor.md). Start the simulator about five minutes before this act.

| # | Click or action | What the audience sees |
|---|---|---|
| 1 | Open the slow visual; run **Performance analyzer** and show the DAX timing | Diagnosing a slow page against a 5-second target |
| 2 | Show the Executive Scorecard's timing | Interactive views within target |
| 3 | **Monitoring hub**: the staged refresh failure and its error | Refresh failure root cause |
| 4 | **Capacity Metrics** app: the spike and the item consuming capacity | Capacity bottleneck |
| 4a | **Fabric Estate Monitor > Live operations**: the same spike every 30 seconds, the overloaded state, and **Top capacity consumers** naming the item and user | Live capacity and throttling, attributed |
| 4b | Live job and refresh feed: the failed refresh, with its error, seconds after it happened (and the Teams alert, if set up) | Real-time failure detection and alerting |
| 5 | Lineage to the source item behind the failure | Source issue identified |
| 6 | **Estate Monitor > Inventory and change**: every workspace and item, the live change feed and workspaces without a user admin. Then the governance notebook: items unused for 90 days, using the monitor's activity history | Live bulk inventory, change tracking and stale content |
| 7 | Show the orphaned-workspace list and the guarded ownership and archive section | Ownership reassignment and archival |
| 8 | Show licensing or capacity usage by user type | License and capacity optimization |

**Talk track**
- "Your platform team doesn't need third-party tools to find out why something is slow or failing. The telemetry is native, from the visual down to the source."
- "At your scale, keeping the estate clean matters: find stale content, fix ownership when people leave, archive safely and right-size licensing."
- "Capacity Metrics tells you what happened. The Estate Monitor tells you what's happening now, across every workspace, and alerts you before users call."

**Capability shown:** performance under an agreed workload; platform and capacity monitoring; report retirement; inputs to a cost model.
**Handoff:** "Back to you to bring it together."

---

## Close and recap

"You saw one story: two legacy organizations' data brought together without moving off their platforms, certified once, questioned in plain language under the right security, explained with a human in the loop, rolled up to the board, and audited and governed at every step. That's a single source of truth, AI for every employee, and governance at your scale."

## Coverage of common RFP asks

| Asked to see | Where |
|---|---|
| Executive scorecard using certified KPIs | Act 5 |
| Lineage from source to semantic definition to report | Act 2 |
| Consistent metric results across experiences | Acts 3 and 5 |
| Role- and row-level security | Act 3 |
| Natural-language questions with grounded answers and traceability | Act 3 |
| Summaries and anomaly explanations with human review | Acts 4 and 5 |
| Auditing and administration | Acts 6 and 7 |
| Coexistence with existing platforms (Snowflake, SQL) and Microsoft 365 | Act 2; Acts 3 and 5 (Microsoft 365, recorded) |
| Performance under an agreed workload | Act 7 |
| Real-time monitoring and alerting of platform health, usage and change | Act 7 (Estate Monitor) |
