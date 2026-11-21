/* =====================================================================
   Combined-Data warehouse: schema and tables
   Run once in the Combined-Data warehouse (Fabric Data Warehouse).
   Creates the [Combine-Data] schema that the semantic model reads from.
   ===================================================================== */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Combine-Data')
    EXEC('CREATE SCHEMA [Combine-Data]');
GO

DROP TABLE IF EXISTS [Combine-Data].[dim_branch];
CREATE TABLE [Combine-Data].[dim_branch]
(
    SourceCU          VARCHAR(50)  NOT NULL,   -- 'Contoso CU' or 'Fabrikam CU'
    SourceBranchKey   VARCHAR(20)  NOT NULL,   -- e.g. CON-BR1001, FAB-BR2002 (unique across both CUs)
    BranchId          VARCHAR(20)  NOT NULL,
    BranchName        VARCHAR(100) NOT NULL,
    Region            VARCHAR(20)  NOT NULL,   -- North, South, East, West (drives RLS)
    State             VARCHAR(2)   NULL
);

DROP TABLE IF EXISTS [Combine-Data].[dim_month];
CREATE TABLE [Combine-Data].[dim_month]
(
    MonthStart DATE NOT NULL
);

DROP TABLE IF EXISTS [Combine-Data].[fact_monthly_kpi];
CREATE TABLE [Combine-Data].[fact_monthly_kpi]
(
    SourceCU            VARCHAR(50) NOT NULL,
    SourceBranchKey     VARCHAR(20) NOT NULL,
    MonthStart          DATE        NOT NULL,
    BranchId            VARCHAR(20) NOT NULL,
    Region              VARCHAR(20) NOT NULL,
    LoansBooked         BIGINT      NULL,
    DepositGrowthPct    FLOAT       NULL,
    NPS                 FLOAT       NULL,
    DelinquencyRatePct  FLOAT       NULL,
    DigitalAdoptionPct  FLOAT       NULL
);

DROP TABLE IF EXISTS [Combine-Data].[fact_driver_breakdown];
CREATE TABLE [Combine-Data].[fact_driver_breakdown]
(
    SourceCU         VARCHAR(50)  NOT NULL,
    SourceBranchKey  VARCHAR(20)  NOT NULL,
    MonthStart       DATE         NOT NULL,
    BranchId         VARCHAR(20)  NOT NULL,
    DriverName       VARCHAR(50)  NOT NULL,
    ImpactScore      FLOAT        NULL,
    DriverValue      FLOAT        NULL
);

DROP TABLE IF EXISTS [Combine-Data].[glossary_kpi_definitions];
CREATE TABLE [Combine-Data].[glossary_kpi_definitions]
(
    KPI          VARCHAR(50)  NOT NULL,
    Definition   VARCHAR(400) NULL,
    Owner        VARCHAR(100) NULL,
    Calculation  VARCHAR(400) NULL
);

DROP TABLE IF EXISTS [Combine-Data].[security_user_scope];
CREATE TABLE [Combine-Data].[security_user_scope]
(
    SourceCU  VARCHAR(50)  NOT NULL,   -- 'Enterprise' (the scope applies across both CUs)
    UserUPN   VARCHAR(256) NOT NULL,
    RoleName  VARCHAR(50)  NULL,
    Region    VARCHAR(20)  NOT NULL    -- North / South / East / West / ALL
);
GO
