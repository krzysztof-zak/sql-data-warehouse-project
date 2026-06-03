/*
==========================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
==========================================================================
Script Purpose:
    This Script Loads Data into the 'bronze' Schema Tables form Source CSV Files.
    It Performs following actions:
      -Truncates bronze Tables before Loading the Data.
      -Uses 'BULK INSERT' command to Load CSV Files into Bronze Tables.

Parameters:
    -None
  This Stored Procedure does not accept any Parameters or return any Values.

Usage Example:
  EXECUTE bronze.load_bronze;
  ==========================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
	SET @batch_start_time = GETDATE();
		PRINT '==========================================';
		PRINT 'Loading the Bronze Layer';
		PRINT '==========================================';

		PRINT '------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------';
		
		SET @start_time = GETDATE();
		PRINT '>>Truncating Table bronze.crm_cust_info';
		TRUNCATE TABLE [bronze].[crm_cust_info]
		PRINT '>>Inserting Data into Table bronze.crm_cust_info';
		BULK INSERT [bronze].[crm_cust_info]
		from 'C:\Users\user\Desktop\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @end_time, @start_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table bronze.crm_prd_info';
		TRUNCATE TABLE [bronze].[crm_prd_info]
		PRINT '>>Inserting Data into Table bronze.crm_prd_info';
		BULK INSERT [bronze].[crm_prd_info]
		from 'C:\Users\user\Desktop\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @end_time, @start_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table bronze.crm_sales_details';
		TRUNCATE TABLE [bronze].[crm_sales_details]
		PRINT '>>Inserting Data into Table bronze.crm_sales_details';
		BULK INSERT [bronze].[crm_sales_details]
		from 'C:\Users\user\Desktop\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @end_time, @start_time) AS NVARCHAR) + ' seconds';

		PRINT '------------------------------------------';
		PRINT 'Loading CRM Tables is Completed';
		PRINT '------------------------------------------';
		PRINT '------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table bronze.erp_cust_az12';
		TRUNCATE TABLE [bronze].[erp_cust_az12]
		PRINT '>>Inserting Data into Table bronze.erp_cust_az12';
		BULK INSERT [bronze].[erp_cust_az12]
		from 'C:\Users\user\Desktop\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @end_time, @start_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table bronze.erp_loc_a101';
		TRUNCATE TABLE [bronze].[erp_loc_a101]
		PRINT '>>Inserting Data into Table bronze.erp_loc_a101';
		BULK INSERT [bronze].[erp_loc_a101]
		from 'C:\Users\user\Desktop\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @end_time, @start_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE [bronze].[erp_px_cat_g1v2]
		PRINT '>>Inserting Data into Table bronze.erp_px_cat_g1v2';
		BULK INSERT [bronze].[erp_px_cat_g1v2]
		from 'C:\Users\user\Desktop\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @end_time, @start_time) AS NVARCHAR) + ' seconds';
		SET @batch_end_time = GETDATE();
		PRINT '------------------------------------------';
		PRINT 'Loading ERP Tables is Completed';
		PRINT '------------------------------------------';
		PRINT 'Loading of the Bronze Layer is Completed'
		PRINT '>> Load Duration of the Whole Database: ' + CAST(DATEDIFF(second, @batch_end_time, @batch_start_time) AS NVARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
		PRINT '==========================================';
		PRINT 'ERROR OCCURED DURING LOADING OF THE BRONZE LAYER'
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==========================================';
	END CATCH
	
END
