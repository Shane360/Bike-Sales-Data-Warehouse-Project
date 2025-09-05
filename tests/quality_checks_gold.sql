/*
==============================================================================
QUALITY CHECKS
==============================================================================

Script Purpose:
	This script performs  quality checks for data integrity, consistency, and 
  accuracy of the Gold Layer. It includes checks for:
	- Uniqueness of surrogate keys in dimensions tables
	- Refertntial integrity between fact and dimension tables
	- Validation of relationships in the data model for analytical purposes

Usage Notes:
	- Run these checks after creating the views for Gold Layer.
	- Investigate and resolve any discrepancies found during the checks
===============================================================================
*/


-- ==========================================================
-- Checking 'gold.customer_key'
-- ==========================================================
-- Check for Uniqueness of Customer Key 
-- Expectation: No Results
SELECT
	customer_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;




-- ==========================================================
-- Checking 'gold.product_key'
-- ==========================================================
-- Check for Uniqueness of the Primary Key
-- Expectation: No Results
SELECT
	product_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ===========================================================
-- Checking 'gold.fact_sales'
-- ===========================================================
-- Check if all dimension tables can successfiully connect to the fact table
SELECT f.customer_key, f.product_key
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key 
WHERE p.product_key IS NULL OR c.customer_key IS NULL
