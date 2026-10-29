USE orderswarehouse;
GO

/*
=====================================================================
Procedure:  bronze.load_bronze
Purpose:    Full reload of the Bronze layer from the two CSV files.
            Each run empties the tables and loads the files again,
            so the procedure can be re-run safely.
Usage:      EXEC bronze.load_bronze;
Notes:      - Data is loaded exactly as it is in the files (no cleaning).
            - The file paths are read by the SQL Server service, so it
              must have permission to read that folder.
=====================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;   -- hide "rows affected" noise, keep our own messages

    DECLARE @start_time      DATETIME2,   -- start of each table load
            @batch_start     DATETIME2,   -- start of the whole procedure
            @rows            INT;         -- rows loaded into a table

    BEGIN TRY
        SET @batch_start = SYSDATETIME();
        PRINT '=====================================================';
        PRINT 'Loading Bronze layer';
        PRINT '=====================================================';

        -- -----------------------------------------------------------
        -- Table 1: customers
        -- -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating table: bronze.raw_customer';
        TRUNCATE TABLE bronze.raw_customer;      -- remove old data so we never load twice

        PRINT '>> Loading table: bronze.raw_customer';
        BULK INSERT bronze.raw_customer
        FROM 'C:\Users\StanleySONGOK\OneDrive - DCBI.aero\Desktop\Engineering projects\raw_customer.csv'
        WITH (
            FORMAT          = 'CSV',      -- understands quoted values like "2.931,28"
            FIELDQUOTE      = '"',        -- text inside double quotes is one value
            FIELDTERMINATOR = ',',        -- columns are separated by commas
            ROWTERMINATOR   = '0x0d0a',   -- rows end with a Windows line break (\r\n)
            FIRSTROW        = 2,          -- skip the header row
            TABLOCK                       -- lock the table for a faster load
        );

        SELECT @rows = COUNT(*) FROM bronze.raw_customer;
        PRINT '>> Rows loaded: ' + CAST(@rows AS VARCHAR(10)) + ' (expected 500)';
        PRINT '>> Load time: ' + CAST(DATEDIFF(MILLISECOND, @start_time, SYSDATETIME()) AS VARCHAR(10)) + ' ms';
        PRINT '-----------------------------------------------------';

        -- -----------------------------------------------------------
        -- Table 2: orders
        -- -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating table: bronze.raw_orders';
        TRUNCATE TABLE bronze.raw_orders;

        PRINT '>> Loading table: bronze.raw_orders';
        BULK INSERT bronze.raw_orders
        FROM 'C:\Users\StanleySONGOK\OneDrive - DCBI.aero\Desktop\Engineering projects\raw_orders.csv'
        WITH (
            FORMAT          = 'CSV',
            FIELDQUOTE      = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '0x0d0a',
            FIRSTROW        = 2,
            CODEPAGE        = '65001',    -- this file is UTF-8 (keeps the euro symbol)
            TABLOCK
        );

        SELECT @rows = COUNT(*) FROM bronze.raw_orders;
        PRINT '>> Rows loaded: ' + CAST(@rows AS VARCHAR(10)) + ' (expected 900)';
        PRINT '>> Load time: ' + CAST(DATEDIFF(MILLISECOND, @start_time, SYSDATETIME()) AS VARCHAR(10)) + ' ms';
        PRINT '-----------------------------------------------------';

        PRINT 'Bronze load completed in '
            + CAST(DATEDIFF(MILLISECOND, @batch_start, SYSDATETIME()) AS VARCHAR(10)) + ' ms';
    END TRY
    BEGIN CATCH
        -- If anything fails, show what went wrong
        PRINT '=====================================================';
        PRINT 'ERROR while loading the Bronze layer';
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Number:  ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Line:    ' + CAST(ERROR_LINE() AS VARCHAR(10));
        PRINT '=====================================================';
        THROW;   -- pass the error on so a calling job also fails
    END CATCH
END;
GO

-- Run the procedure
EXEC bronze.load_bronze;
