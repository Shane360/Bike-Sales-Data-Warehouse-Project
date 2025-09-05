/*
================================================================================
DDL SCRIPT: Create Gold Views
================================================================================
Purpose:
	This script creates views in the 'gold' schema, in the Data warehouse.
	The Gold Layer represents the final dimension and fact tables (Star Schema).

	Each view performs transformations and combines data from the silver layer 
	to produce a clean, enriched, and business_ready dataset.

Usage:
	- These views can be queried directly for analytics and reporting. 
---------------------------------------------------------------------------------
*/


-- ================================================================================
-- Create Dimension: gold.dim_customers
-- ================================================================================


-------------------- Customer Dim Table ---------------------
-- Surrogate Key (for PK), Data Integration, rename columns properly
IF OBJECT_ID ('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	l.cntry AS country,
	ci.cst_marital_status as marital_status,
	CASE 
		WHEN ci.cst_gndr != 'N/A' then ci.cst_gndr -- CRM is the Master Source for the Customer Info
		ELSE COALESCE(ca.gen, 'N/A')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 l ON ci.cst_key = l.cid;


-------------------- Product Dim Table -----------------------
-- Surrogate Key (for PK), rename columns properly
IF OBJECT_ID ('gold.dim_products', 'V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY p.prd_start_dt, p.prd_key) AS product_key,
	p.prd_id AS product_id,
	p.prd_key AS product_number,
	p.prd_nm AS product_name,
	p.cat_id AS category_id,
	px.cat AS category,
	px.subcat AS subcategory,
	px.maintenance AS maintenance,
	p.prd_cost AS cost,
	p.prd_line AS product_line,
	p.prd_start_dt AS start_date
FROM silver.crm_prd_info p
LEFT JOIN silver.erp_px_cat_g1v2 px
ON p.cat_id = px.id
WHERE p.prd_end_dt IS NULL -- Filter out historical data
;

-------------------- Sales Fact Table -----------------------
-- Join surrogate keys from dim tables, rename accordingly
IF OBJECT_ID ('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cs.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS sales_quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cs
ON sd.sls_cust_id = cs.customer_id
;
