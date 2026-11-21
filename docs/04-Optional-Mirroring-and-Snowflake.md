# Optional: mirrored SQL sources and Snowflake

The default build loads the two legacy credit unions into lakehouses from CSV. To tell the "your source systems stay where they are" story in Act 2 with live replication, build the legacy sources as databases and mirror them into Fabric instead. The warehouse procedure, semantic model and report don't change.

## Option A: Azure SQL Database (or SQL Server) mirrors

1. Create two **empty** Azure SQL databases, for example `contoso-cu-legacy` and `fabrikam-cu-legacy`. The Basic or General Purpose serverless tier is enough.
2. Run `sql/source/Contoso_CU_source.sql` in the first and `sql/source/Fabrikam_CU_source.sql` in the second. Each script creates ten tables with primary keys (mirroring requires them) and inserts the sample rows.
3. Meet the mirroring prerequisites for Azure SQL Database: a system-assigned managed identity on the logical server, and a login that Fabric can use. See *Mirroring Azure SQL Database* on Microsoft Learn for the current steps.
4. In the Fabric workspace select **New item > Mirrored Azure SQL Database**, connect to each database, select all tables and start mirroring. Name the mirrored databases **Contoso_CU** and **Fabrikam_CU**, the same names the lakehouses would have, so `usp_Load_Combined` works unchanged.
5. Run `notebooks/Load_Source_Data.ipynb` with `LOAD_LEGACY_SOURCES = False`. It creates and loads only **Enterprise_Ref**.
6. Continue with the warehouse steps in the setup guide.

For on-premises SQL Server, use **Mirrored SQL Server** with an on-premises data gateway. The scripts run on SQL Server 2016 and later.

**Demo tip:** to show replication live, update a row in the source during Act 2 (for example raise a branch's `LoansBooked`), wait for the mirror to replicate, rerun the procedure and refresh the model.

**Cost tip:** pause or stop mirroring between rehearsals. Mirroring itself is free up to a capacity-based storage allowance, but the source databases and any frequent refreshes are not.

## Option B: Snowflake

Fabric can mirror a Snowflake database the same way. Load one legacy credit union's CSVs into Snowflake tables with the same names and columns, create a **Mirrored Snowflake** item named `Contoso_CU`, and keep the other source as a lakehouse or SQL mirror. The rest of the build is unchanged.

Be explicit with the audience about which source is which. If you use SQL Server as a stand-in for Snowflake, say so.

## Option C: shortcuts to existing Delta or Iceberg data

If the source data already lives in ADLS Gen2, S3 or Snowflake-managed Iceberg tables, create **OneLake shortcuts** in the Contoso_CU and Fabrikam_CU lakehouses under `Tables`, using the table names above. Nothing is copied.
