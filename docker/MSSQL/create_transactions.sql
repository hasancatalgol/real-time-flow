-- Create the database if it doesn't exist
IF DB_ID('sipay') IS NULL
BEGIN
    CREATE DATABASE sipay;
END
GO

-- Switch to the new database
USE sipay;
GO

-- Try to start SQL Server Agent (might not work in Docker)
BEGIN TRY
    EXEC xp_servicecontrol 'START', 'SQLServerAgent';
END TRY
BEGIN CATCH
    PRINT '⚠️ SQL Server Agent may not be available in this container environment.';
END CATCH
GO

-- Enable CDC at the database level if not already enabled
IF NOT EXISTS (
    SELECT 1 FROM sys.databases WHERE name = 'sipay' AND is_cdc_enabled = 1
)
BEGIN
    EXEC sys.sp_cdc_enable_db;
END
GO
    -- Create the table if it doesn't exist
    IF OBJECT_ID('dbo.transactions', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.transactions (
            txcorrelationid                    BIGINT        NOT NULL,
            tenantid                           BIGINT        NOT NULL,
            txgroupcorrelationid               BIGINT        NOT NULL,
            txrefcorrelationid                 BIGINT        NOT NULL,
            walletid                           BIGINT        NOT NULL,
            transactiontypecode                INT           NOT NULL,
            transactionstatuscode              INT           NOT NULL,
            resultcode                         VARCHAR(20)   NOT NULL,
            txadditionaldatajson               VARCHAR(MAX)  NOT NULL,
            createddateutc                     DATETIMEOFFSET NOT NULL,
            updateddateutc                     DATETIMEOFFSET,
            completeddateutc                   DATETIMEOFFSET,
            financialprocesscompleteddateutc   DATETIMEOFFSET,
            isfinancialprocesscompleted        BIT           NOT NULL,
            towalletid                         BIGINT        NOT NULL,
            txbaseamount                       NUMERIC(18,4),
            txadditionalfee                    NUMERIC(18,4),
            txamountwithadditionalfee          NUMERIC(18,4),
            currencycode                       VARCHAR(10)   NOT NULL,
            txenduserpreviewjson               VARCHAR(MAX)  NOT NULL,
            fromdescription                    VARCHAR(500)  NOT NULL,
            todescription                      VARCHAR(500)  NOT NULL,
            kyclevelcode                       VARCHAR(10)   NOT NULL,
            fromaccounttypeid                  VARCHAR(5)    NOT NULL,
            fromaccountid                      BIGINT        NOT NULL,
            fromwalletnumber                   VARCHAR(50)   NOT NULL,
            fromaccountnumber                  VARCHAR(50)   NOT NULL,
            toaccountnumber                    VARCHAR(50)   NOT NULL,
            toaccounttypeid                    VARCHAR(5)    NOT NULL,
            toaccountid                        BIGINT        NOT NULL,
            towalletnumber                     VARCHAR(50)   NOT NULL,
            summarycreateddateutc              DATETIMEOFFSET NOT NULL,
            isneedsettlement                   BIT           NOT NULL,
            settlementday                      INT           NOT NULL,
            exttransactionid                   VARCHAR(100),
            channeltype                        VARCHAR(20),
            sourcetype                         VARCHAR(20),
            mediaidentifier                    VARCHAR(50),
            terminalno                         VARCHAR(20),
            mediatype                          VARCHAR(10),
            providerid                         VARCHAR(20),
            toaccounttxbaseamount              NUMERIC(18,4),
            toaccounttxadditionalfee           NUMERIC(18,4),
            toaccounttxamountwithadditionalfee NUMERIC(18,4),
            settlementtypeid                   INT,
            isadjustlimitsuccessprocessed      BIT,
            isadjustlimitcancelprocessed       BIT,
            tenantname                         VARCHAR(250),
            tenantcode                         VARCHAR(50),
            ishidden                           BIT,
            ishiddenforreceiver                BIT,
            ishiddenforsender                  BIT,
            fromextaccountnumber               VARCHAR(50),
            toextaccountnumber                 VARCHAR(50),
            fromgroupcode                      VARCHAR(50),
            togroupcode                        VARCHAR(50),
            receiptnumber                      VARCHAR(50),
            CONSTRAINT PK_transactions PRIMARY KEY (txcorrelationid)
        );
    END
    GO

-- Disable CDC if already enabled on the table
IF EXISTS (
    SELECT 1 FROM sys.tables WHERE name = 'transactions' AND is_tracked_by_cdc = 1
)
BEGIN
    EXEC sys.sp_cdc_disable_table
        @source_schema = N'dbo',
        @source_name = N'transactions',
        @capture_instance = N'dbo_transactions';
END
GO

-- Enable CDC on the table
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'transactions',
    @role_name     = NULL,
    @capture_instance = N'dbo_transactions';
GO

BULK INSERT dbo.transactions
FROM '/var/opt/mssql/dataset.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FORMAT = 'CSV',
    TABLOCK
);
GO

-- Force checkpoint to flush CDC metadata
CHECKPOINT;
GO