## Data Dictionary - Gold Layer

### Overview

The Gold Layer represents the business-level data, structured to support analytical and reporting use cases. It consists of **dimension tables** and **a fact table** for specific business metrics.

---

1. **gold.dim_customers**
    - **Purpose:** Stores customer details enriched with demographic and geographic data.
    - **Columns:**
    

| **Column Name** | **Data Type** | Description |
| --- | --- | --- |
| customer_key | BIGINT | Surrogate key uniquely identifying each customer |
| customer_id | INT | Unique numeric identifier assinged to each customer |
| customer_number | NVARCHAR(50) | Alphanumeric identifier representing the customer, used for tracking and referencing |
| first_name | NVARCHAR(50) | Customers first name |
| last_name | NVARCHAR(50) | Customers last name or family name |
| country | NVARCHAR(50) | customers country of residence (e.g, ‘Germany’) |
| marital_status | NVARCHAR(50) | Marital status of the customer (e.g., ‘Married’, ‘SIngle’) |
| gender | NVARCHAR(50) | Customer’s gender (e.g., ‘Male’, ‘Female’, ‘N/A’) |
| birth_date | DATE | Customer’s date of birth formatted as YYYY-MM-DD (e.g., 1984-12-04) |
| create_date | DATE | Date the customers record was created |

2. **gold.dim_products**
    - **Purpose:** Provides information about the products and their attributes.
    - **Columns:**
    

| **Column Name** | **Data Type** | Description |
| --- | --- | --- |
| product_key | BIGINT | Surrogate key uniquely identifying each product record in the dimension tabl |
| product_id | INT | A unique identifier assinged to the product for internal tracking and referrcing. |
| product_number | NVARCHAR(50) | A structured alphanumeric code representing the product, often used for categorization inventory. |
| product_name | NVARCHAR(50) | Descriptive name  of the product, including keys such as type, color and size |
| category_id | NVARCHAR(50) | A unique identifier of the product’s category, linking to it’s high-level calssification |
| category | NVARCHAR(50) | The broader classification of the product (e.g., Bikes, components, e.t.c.,) to group related terms |
| subcategory | NVARCHAR(50) | More detailed classification of the product within the category |
| maintenance | NVARCHAR(50) | indicates whether the product requires maintenance (e.g., ‘Yes’ and “No’) |
| cost | INT | The cost or base price of the product, measured in monetary units |
| product_line | NVARCHAR(50) | The speciic product line or series to which the product belongs (e.g., Road, Mountain) |
| start_date | DATE | Date the product became available for sale or use  |

3. **gold.fact_sales**
- **Purpose:** Stores transactional sales data for analytical purposes.
- **Columns:**

| **Column Name** | **Data Type** | Description |
| --- | --- | --- |
| order_number | NVARCHAR(50) | Unique alphanumeric identifier representing the customer, used for tracking and referencing  |
| product_key | BIGINT | Surrogate key linking the order to the product dimension table  |
| customer_key | BIGINT | Surrogate key linking the order to the customer dimension table |
| order_data | DATE | Date when the order was placed |
| shipping_date | DATE | Date when the order was shipped to custom |
| due_date | DATE | Date when the order payment was due |
| sales_amount | INT | Total monetary value of the sale for the line item in whole currency units (e.g., 30) |
| quantity | INT | Number of units of the product ordered for the line item (e.g., 2) |
| price | INT | Customer’s date of birth formatted as YYYY-MM-DD (e.g., 1984-12-04) |
|  |  |  |
