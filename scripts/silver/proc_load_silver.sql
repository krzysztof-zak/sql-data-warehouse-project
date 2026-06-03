/*
==========================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==========================================================================
Script Purpose:
    This Script Loads Data into the 'silver' Schema Tables from 'bronze' Schema Tables.
    It Performs following actions:
      -Truncates silver Tables before Loading the Data.
	  -Cleans and Standardizes Data according to naming convention and makes it more User Friendly
      -Uses 'INSERT' command to Load cleaned Data from bronze Layer into silver Layer Tables .

Parameters:
    -None
  This Stored Procedure does not accept any Parameters or return any Values.

Usage Example:
  EXECUTE silver.load_silver;
  ==========================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE()
		PRINT '==========================================';
		PRINT 'Loading Silver Layer';
		PRINT '==========================================';
		PRINT '-------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-------------------------------------------';
		SET @start_time = GETDATE()
		PRINT '>>Truncating Table silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>>Inserting Data Into silver.crm_cust_info'
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		--Cleaning data in bronze.crm_cust_info
		SELECT
			cst_id,
			cst_key,
			-- Deleting leading and trailing spaces from firstname and lastname
			-- (marital_status and gndr were checked and don't contain unwanted spaces)
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			-- Making marital_status and gndr more user friendly and easier to read
			CASE
				WHEN UPPER(cst_marital_status) = 'M' THEN 'Married'
				WHEN UPPER(cst_marital_status) = 'S' THEN 'Single'
				ELSE 'N/A'
			END AS cst_marital_status,
			CASE
				WHEN UPPER(cst_gndr) = 'M' then 'Male'
				WHEN UPPER(cst_gndr) = 'F' then 'Female'
				ELSE 'N/A'
			END AS cst_gndr,
			cst_create_date
		FROM (
			SELECT
				*,
				-- Flagging duplicates in order to remove them from data
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_most_recent
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t
		WHERE flag_most_recent = 1;
		SET @end_time = GETDATE()
		PRINT '>>Data loaded into silver.crm_cust_info. Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'

		SET @start_time = GETDATE()
		PRINT '>>Truncating Table silver.crm_prd_info'
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>>Inserting Data Into silver.crm_prd_info'
		INSERT INTO silver.crm_prd_info
		(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		--Cleaning crm_prd_info
		SELECT
			prd_id,
			--Dividing prd_key into two separate columns cat_id and prd_key
			--Later cat_id can be used to join to erp_px_cat_g1v2 id
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
			SUBSTRING(prd_key, 7, len(prd_key)) AS prd_key,
			prd_nm,
			-- Using ISNULL to substitute NULLS with 0s in prd_cost
			ISNULL(prd_cost, 0) AS prd_cost,
			--Making prd_line more user friendly and standardized
			CASE UPPER(TRIM(prd_line))
					WHEN 'R' THEN 'Road'
					WHEN 'M' THEN 'Mountain'
					WHEN 'S' THEN 'other Sales'
					WHEN 'T' THEN 'Touring'
					ELSE 'N/A'
				end as prd_line,
			--Casting prd_start_dt and prd_end_dt as DATE
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS DATE) AS prd_end_dt
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE()
		PRINT '>>Data loaded into silver.crm_prd_info. Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'

		SET @start_time = GETDATE()
		PRINT '>>Truncating Table silver.crm_sales_details'
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>>Inserting Data Into silver.crm_sales_details'
		INSERT INTO silver.crm_sales_details
		(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		--Cleaning crm_sales_details

		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			--Making sure Date in sls_order_dt, sls_ship_dt, sls_due_dt is viable, if so CASTing it as DATE
			--Otherwise it will be presented as NULLs
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			--If data quality in sls_sales is poor it will be derived from sls_price and sls_quantity
			CASE
				WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_price) * sls_quantity
					 THEN ABS(sls_price) * sls_quantity
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			--If data quality in sls_price is poor it will be derived from sls_sales and sls_quantity
			CASE WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity, 0)
				 ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE()
		PRINT '>>Data loaded into silver.crm_sales_details. Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'

		PRINT '------------------------------------------';
		PRINT 'Loading CRM Tables is Completed';
		PRINT '------------------------------------------';
		PRINT '------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------';

		SET @start_time = GETDATE()
		PRINT '>>Truncating Table silver.erp_cust_az12'
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>>Inserting Data Into silver.erp_cust_az12'
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		--Cleaning erp_cust_az12

		SELECT
			--Removing 'NAS' from beggining of the cid in order to be able to join it
			--to crm_cust_info cst_key
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				 ELSE cid
			END AS cid,
			--Removing bdates more recent than current date
			CASE WHEN bdate > GETDATE() THEN NULL
				 ELSE bdate
			END AS bdate,
			--Removing NULLs and empty strings and aking data in gen more user friendly in gen
			CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				 ELSE 'N/A'
			END AS gen
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE()
		PRINT '>>Data loaded into silver.erp_cust_az12. Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'

		SET @start_time = GETDATE()
		PRINT '>>Truncating Table silver.erp_loc_a101'
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>>Inserting Data Into silver.erp_loc_a101'
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		--Cleaning erp_loc_a101

		SELECT
			--Removing '-' from cid in order to be able to join it to crm_cust_info cst_key 
			REPLACE(cid, '-', '') AS cid,
			--Standardizing cntry and making it more user friendly
			CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				 WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'N/A'
				 ELSE cntry
			END AS cntry
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE()
		PRINT '>>Data loaded into silver.erp_loc_a101. Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'

		SET @start_time = GETDATE()
		PRINT '>>Truncating Table silver.erp_px_cat_g1v2'
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>>Inserting Data Into silver.erp_px_cat_g1v2'
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)

		--Data in bronze.erp_p_cat_g1v2 has good quality so it does not need cleaning
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE()
		PRINT '>>Data loaded into silver.erp_px_cat_g1v2. Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		SET @batch_end_time = GETDATE();
		PRINT '------------------------------------------';
		PRINT 'Loading ERP Tables is Completed';
		PRINT '------------------------------------------';
		PRINT 'Loading of the Silver Layer is Completed'
		PRINT '>>Load Duration of the Whole Database: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
		PRINT '==========================================';
		PRINT 'ERROR OCCURED DURING LOADING OF THE SILVER LAYER'
		PRINT 'ERROR MESSAGE ' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGE ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==========================================';
	END CATCH
	
END
