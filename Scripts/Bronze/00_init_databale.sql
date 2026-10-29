/*
=====================================================================
Script:   00_init_database.sql
Purpose:  Create the orderswarehouse database and the three
          medallion layers (bronze, silver, gold) as schemas.
WARNING:  If orderswarehouse already exists, it is DROPPED and all
          its data is permanently deleted. Use on development only.
=====================================================================
*/

-- Move to master: a database cannot be dropped while you are inside it
USE master;
GO

-- Drop and recreate the database if it already exists,
-- so the script can be re-run from a clean start
IF DB_ID('orderswarehouse') IS NOT NULL
BEGIN
    -- Allow one connection only, and disconnect everyone else
    -- (rolls back their unfinished work) so the drop is not blocked
    ALTER DATABASE orderswarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    -- Permanently delete the old database
    DROP DATABASE orderswarehouse;
END
GO

-- Create a new, empty database
CREATE DATABASE orderswarehouse;
GO

-- FIX: switch into the new database, otherwise the schemas below
-- would be created in master
USE orderswarehouse;
GO

-- Bronze layer: raw data loaded exactly as it comes from the source
CREATE SCHEMA bronze;
GO

-- Silver layer: cleaned, standardized and de-duplicated data
CREATE SCHEMA silver;
GO

-- Gold layer: business-ready star schema (views for analysts and ML)
CREATE SCHEMA gold;
GO
