/* Run after EXEC [Combine-Data].[usp_Load_Combined]; */

-- 1. Both legacy credit unions are present (Act 2 click 3). Expect 440 rows and 20 branches each.
SELECT SourceCU, COUNT(*) AS KpiRows, COUNT(DISTINCT SourceBranchKey) AS Branches
FROM   [Combine-Data].[fact_monthly_kpi]
GROUP  BY SourceCU;

-- 2. Regions must be exactly East, North, South, West (RLS depends on it).
SELECT Region, COUNT(*) AS Branches FROM [Combine-Data].[dim_branch] GROUP BY Region ORDER BY Region;

-- 3. The branch that stands out (Act 4): Allentown, FAB-BR2002.
SELECT TOP 5 b.BranchName, b.SourceBranchKey, f.MonthStart, f.DelinquencyRatePct, f.NPS
FROM   [Combine-Data].[fact_monthly_kpi] f
JOIN   [Combine-Data].[dim_branch] b ON b.SourceBranchKey = f.SourceBranchKey
WHERE  f.MonthStart = (SELECT MAX(MonthStart) FROM [Combine-Data].[fact_monthly_kpi])
ORDER  BY f.DelinquencyRatePct DESC;

-- 4. RLS users loaded with your tenant domain (no '{tenant}' placeholders left).
SELECT * FROM [Combine-Data].[security_user_scope];
