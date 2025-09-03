/*
==============================================================================
QUALITY CHECKS
==============================================================================

Script Purpose:
	This script performs various quality checks for data consistency, accuracy
	, and standardization across the 'silver' schema. It includes checks for:
	- Null or duplicate primary keys.
	- Unwanted spaces in string fields
	- Data standardization and consistency
	- Invalid data ranges and orders
	- Data consistency between related fields


Usage Notes:
	- Run these checks after data loading Silver Layer.
	- Investigate and resolve any discrepancies found during the checks
===============================================================================
*/


/*
===============================================================================
Checking the 'silver.crm_cust_info'
===============================================================================
*/
-- Check for NULLS or Duplicates in the Primary Key
-- Expectation: No results
SELECT
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- Check for Unwanted Spaces in 
-- Expectation: No Results

SELECT 
	cst_key,
	cst_firstname,
	cst_lastname
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key)
OR cst_firstname != TRIM(cst_firstname)
OR cst_lastname != TRIM(cst_lastname);

SELECT * FROM silver.crm_cust_info;


-- Data Standardization and Consistency
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;


/*
===============================================================================
Checking the 'silver.crm_prd_info'
===============================================================================
*/

SELECT * FROM silver.crm_prd_info;

-- Check for duplicates
SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- Check for unwanted spaces in the Prd_name
SELECT 
	prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for Negative Numbers
-- Expectations: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;


-- Check the Date Order
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;



/*
===============================================================================
Checking the 'silver.crm_sales_details'
===============================================================================
*/

SELECT * FROM silver.crm_sales_details

-- Check for unwanted spaces
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)
OR sls_prd_key != TRIM(sls_prd_key);

-- Its a Fact table so duplicates are allowed

-- Check the integrity of the columns: WHETHER cust_id(Sales_details) IN cst_id(Cust_Info)
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);


-- Check the Date columns
SELECT 
sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt IS NULL
OR sls_ship_dt > '20500101'
OR sls_ship_dt < '19000101';


-- Further check for invalid Date orders
-- Check whether the due dates that are lower than the order dates

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_due_dt
OR sls_ship_dt > sls_due_dt;


-- Check the sales, quantity and price columns
-- Business Rules
-- a. Sales MUST = Quantity * Price
-- b. Negative nos., 0's and NULLs are not allowed.
-- Run checks

SELECT	
	sls_ord_num,
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != (sls_quantity * sls_price)
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;



/*
===============================================================================
Checking the 'silver.erp_cust_a12'
===============================================================================
*/

SELECT * FROM silver.erp_cust_az12
	
-- Check the relationship between this table and the silver.crm_cust_info table
SELECT 
	cid,
	bdate,
	gen
FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);


-- Identify Out-of_Range Dates

SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE()



-- Data Standardization & Consistency (check the gender column)
SELECT DISTINCT 
	gen
FROM silver.erp_cust_az12


/*
===============================================================================
Checking the 'silver.erp_loc_a101'
===============================================================================
*/

-- Check relationship with between this table and the silver.crm_cust_info
SELECT cst_key 
FROM silver.crm_cust_info
WHERE cst_key NOT IN (SELECT cid FROM silver.erp_loc_a101)


-- Check the placement of hyphens in the cst_key
SELECT
	REPLACE(cid, '-', '') AS cid,
	cntry
FROM silver.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info)



-- Data Standardizaion & Consistency (cntry column)
SELECT DISTINCT cntry
FROM silver.erp_loc_a101



/*
===============================================================================
Checking the 'silver.erp_px_cat_g1v2'
===============================================================================
*/

SELECT *
FROM silver.erp_px_cat_g1v2


-- Check for unwanted spaces

SELECT * FROM bronze.erp_px_cat_g1v2
WHERE id != TRIM(id) OR cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

