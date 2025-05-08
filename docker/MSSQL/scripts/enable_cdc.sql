-- Switch to sipay
USE sipay;
GO

-- Enable CDC at the database level if not already enabled
IF NOT EXISTS (
    SELECT 1 FROM sys.databases WHERE name = 'sipay' AND is_cdc_enabled = 1
)
BEGIN
    EXEC sys.sp_cdc_enable_db;
END
GO

-- Disable CDC on the table if already enabled (to reset cleanly)
IF EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE t.name = 'transactions' AND s.name = 'dbo' AND is_tracked_by_cdc = 1
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