/* =====================================================================
   [Combine-Data].[usp_Load_Combined]
   Rebuilds the combined, conformed tables from the two legacy credit
   unions plus the enterprise reference data.

   Sources (same workspace as the warehouse, queried cross-database):
     Contoso_CU      - lakehouse OR mirrored database for legacy Contoso CU
     Fabrikam_CU     - lakehouse OR mirrored database for legacy Fabrikam CU
     Enterprise_Ref  - lakehouse with the certified glossary and RLS scope

   If you name your sources differently, find/replace the three names below.
   Usage:  EXEC [Combine-Data].[usp_Load_Combined];
   ===================================================================== */
CREATE OR ALTER PROCEDURE [Combine-Data].[usp_Load_Combined]
AS
BEGIN
    SET NOCOUNT ON;

    /* ---------- dim_branch ---------- */
    TRUNCATE TABLE [Combine-Data].[dim_branch];
    INSERT INTO [Combine-Data].[dim_branch] (SourceCU, SourceBranchKey, BranchId, BranchName, Region, State)
    SELECT 'Contoso CU',  CONCAT('CON-', BranchId), BranchId, BranchName, Region, State
    FROM   [Contoso_CU].[dbo].[dim_branch]
    UNION ALL
    SELECT 'Fabrikam CU', CONCAT('FAB-', BranchId), BranchId, BranchName, Region, State
    FROM   [Fabrikam_CU].[dbo].[dim_branch];

    /* ---------- dim_month (union of both calendars) ---------- */
    TRUNCATE TABLE [Combine-Data].[dim_month];
    INSERT INTO [Combine-Data].[dim_month] (MonthStart)
    SELECT DISTINCT CAST(MonthStart AS DATE)
    FROM (
        SELECT MonthStart FROM [Contoso_CU].[dbo].[dim_month]
        UNION
        SELECT MonthStart FROM [Fabrikam_CU].[dbo].[dim_month]
    ) m;

    /* ---------- fact_monthly_kpi ---------- */
    TRUNCATE TABLE [Combine-Data].[fact_monthly_kpi];
    INSERT INTO [Combine-Data].[fact_monthly_kpi]
          (SourceCU, SourceBranchKey, MonthStart, BranchId, Region,
           LoansBooked, DepositGrowthPct, NPS, DelinquencyRatePct, DigitalAdoptionPct)
    SELECT 'Contoso CU', CONCAT('CON-', BranchId), CAST(MonthStart AS DATE), BranchId, Region,
           LoansBooked, DepositGrowthPct, NPS, DelinquencyRatePct, DigitalAdoptionPct
    FROM   [Contoso_CU].[dbo].[fact_monthly_kpi]
    UNION ALL
    SELECT 'Fabrikam CU', CONCAT('FAB-', BranchId), CAST(MonthStart AS DATE), BranchId, Region,
           LoansBooked, DepositGrowthPct, NPS, DelinquencyRatePct, DigitalAdoptionPct
    FROM   [Fabrikam_CU].[dbo].[fact_monthly_kpi];

    /* ---------- fact_driver_breakdown ---------- */
    TRUNCATE TABLE [Combine-Data].[fact_driver_breakdown];
    INSERT INTO [Combine-Data].[fact_driver_breakdown]
          (SourceCU, SourceBranchKey, MonthStart, BranchId, DriverName, ImpactScore, DriverValue)
    SELECT 'Contoso CU', CONCAT('CON-', BranchId), CAST(MonthStart AS DATE), BranchId, DriverName, ImpactScore, DriverValue
    FROM   [Contoso_CU].[dbo].[fact_driver_breakdown]
    UNION ALL
    SELECT 'Fabrikam CU', CONCAT('FAB-', BranchId), CAST(MonthStart AS DATE), BranchId, DriverName, ImpactScore, DriverValue
    FROM   [Fabrikam_CU].[dbo].[fact_driver_breakdown];

    /* ---------- certified glossary (one definition per KPI) ---------- */
    TRUNCATE TABLE [Combine-Data].[glossary_kpi_definitions];
    INSERT INTO [Combine-Data].[glossary_kpi_definitions] (KPI, Definition, Owner, Calculation)
    SELECT KPI, Definition, Owner, Calculation
    FROM   [Enterprise_Ref].[dbo].[glossary_kpi_definitions];

    /* ---------- RLS scope (enterprise-wide, by region) ---------- */
    TRUNCATE TABLE [Combine-Data].[security_user_scope];
    INSERT INTO [Combine-Data].[security_user_scope] (SourceCU, UserUPN, RoleName, Region)
    SELECT 'Enterprise', LOWER(UserUPN), RoleName, Region
    FROM   [Enterprise_Ref].[dbo].[security_user_scope];
END;
GO
