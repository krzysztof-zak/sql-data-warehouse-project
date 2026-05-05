/*

======================================================
Create Database and Schemas
======================================================

Script Purpose:
           
           This Script creates a new Database called 'DataWarehouse' after checking if it already exists.
           If Database exists, it is dropped and recreated. Additionally, the script creates three Schemas
           within the Database: 'bronze', 'silver', 'gold'.


WARNING:
           Running this Script will drop the entire 'DataWarehouse' Database if it exists.
           All the data in the database will be permanently deleted. Proceed with caution
           and ensure you have proper backups before running this script
*/

USE master;
GO


--Drop and recreate 'DataWarehouse' database

IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

--Create 'DataWarehouse' Database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

--Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
