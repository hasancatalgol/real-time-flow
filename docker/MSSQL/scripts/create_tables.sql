-- Wait until 'sipay' is fully available
DECLARE @retries INT = 10;
WHILE DB_ID('sipay') IS NULL AND @retries > 0
BEGIN
    WAITFOR DELAY '00:00:01';
    SET @retries -= 1;
END
GO

-- Switch to the sipay database
USE sipay;
GO

-- Create the transactions table only if it doesn't exist
IF OBJECT_ID('dbo.transactions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.transactions (
        txcorrelationid BIGINT NOT NULL PRIMARY KEY,
        tenantid BIGINT NOT NULL,
        txgroupcorrelationid BIGINT NOT NULL,
        txrefcorrelationid BIGINT NOT NULL,
        walletid BIGINT NOT NULL,
        transactiontypecode INT NOT NULL,
        transactionstatuscode INT NOT NULL,
        resultcode VARCHAR(20) NOT NULL,
        txadditionaldatajson VARCHAR(MAX) NOT NULL,
        createddateutc DATETIMEOFFSET NOT NULL,
        updateddateutc DATETIMEOFFSET,
        completeddateutc DATETIMEOFFSET,
        financialprocesscompleteddateutc DATETIMEOFFSET,
        isfinancialprocesscompleted BIT NOT NULL,
        towalletid BIGINT NOT NULL,
        txbaseamount NUMERIC(18,4),
        txadditionalfee NUMERIC(18,4),
        txamountwithadditionalfee NUMERIC(18,4),
        currencycode VARCHAR(10) NOT NULL,
        txenduserpreviewjson VARCHAR(MAX) NOT NULL,
        fromdescription VARCHAR(500) NOT NULL,
        todescription VARCHAR(500) NOT NULL,
        kyclevelcode VARCHAR(10) NOT NULL,
        fromaccounttypeid VARCHAR(5) NOT NULL,
        fromaccountid BIGINT NOT NULL,
        fromwalletnumber VARCHAR(50) NOT NULL,
        fromaccountnumber VARCHAR(50) NOT NULL,
        toaccountnumber VARCHAR(50) NOT NULL,
        toaccounttypeid VARCHAR(5) NOT NULL,
        toaccountid BIGINT NOT NULL,
        towalletnumber VARCHAR(50) NOT NULL,
        summarycreateddateutc DATETIMEOFFSET NOT NULL,
        isneedsettlement BIT NOT NULL,
        settlementday INT NOT NULL,
        exttransactionid VARCHAR(100),
        channeltype VARCHAR(20),
        sourcetype VARCHAR(20),
        mediaidentifier VARCHAR(50),
        terminalno VARCHAR(20),
        mediatype VARCHAR(10),
        providerid VARCHAR(20),
        toaccounttxbaseamount NUMERIC(18,4),
        toaccounttxadditionalfee NUMERIC(18,4),
        toaccounttxamountwithadditionalfee NUMERIC(18,4),
        settlementtypeid INT,
        isadjustlimitsuccessprocessed BIT,
        isadjustlimitcancelprocessed BIT,
        tenantname VARCHAR(250),
        tenantcode VARCHAR(50),
        ishidden BIT,
        ishiddenforreceiver BIT,
        ishiddenforsender BIT,
        fromextaccountnumber VARCHAR(50),
        toextaccountnumber VARCHAR(50),
        fromgroupcode VARCHAR(50),
        togroupcode VARCHAR(50),
        receiptnumber VARCHAR(50)
    );
END
GO