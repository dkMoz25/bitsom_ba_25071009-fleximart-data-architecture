Task 3.1: Star Schema Design Documentation
FlexiMart Data Warehouse - Star Schema Design
Section 1: Schema Overview
FACT TABLE: fact_sales
Grain: One row per product per order line item (transaction line-item level)

Business Process: Sales transactions capturing customer purchases

Measures (Numeric Facts):

quantity_sold (INT): Number of units sold in the transaction
unit_price (DECIMAL(10,2)): Price per unit at the time of sale
discount_amount (DECIMAL(10,2)): Discount applied to the transaction
total_amount (DECIMAL(10,2)): Final amount after discount (quantity × unit_price - discount)
Foreign Keys:

date_key (INT) → dim_date: Links to date dimension for temporal analysis
product_key (INT) → dim_product: Links to product dimension
customer_key (INT) → dim_customer: Links to customer dimension
Purpose: Central fact table storing all sales transactions with measures for revenue analysis, quantity tracking, and discount monitoring.

DIMENSION TABLE: dim_date
Purpose: Date dimension for time-based analysis and temporal reporting

Type: Conformed dimension (can be shared across multiple fact tables)

Attributes:

date_key (INT, PRIMARY KEY): Surrogate key in format YYYYMMDD (e.g., 20240115)
full_date (DATE): Actual calendar date
day_of_week (VARCHAR(10)): Monday, Tuesday, Wednesday, etc.
day_of_month (INT): Day number (1-31)
month (INT): Month number (1-12)
month_name (VARCHAR(10)): January, February, etc.
quarter (VARCHAR(2)): Q1, Q2, Q3, Q4
year (INT): Four-digit year (2023, 2024, etc.)
is_weekend (BOOLEAN): TRUE for Saturday/Sunday, FALSE otherwise
Purpose: Enables drill-down analysis from year → quarter → month → day and supports time-based filtering and grouping.

DIMENSION TABLE: dim_product
Purpose: Product dimension containing product attributes for analysis

Type: Slowly Changing Dimension Type 1 (overwrites changes)

Attributes:

product_key (INT, PRIMARY KEY, AUTO_INCREMENT): Surrogate key
product_id (VARCHAR(20)): Natural key from source system
product_name (VARCHAR(100)): Name of the product
category (VARCHAR(50)): Product category (Electronics, Fashion, Groceries)
subcategory (VARCHAR(50)): Product subcategory for detailed analysis
unit_price (DECIMAL(10,2)): Current list price of the product
Purpose: Provides product context for sales analysis, enables category-based reporting and product performance tracking.

DIMENSION TABLE: dim_customer
Purpose: Customer dimension containing customer attributes for segmentation

Type: Slowly Changing Dimension Type 1 (overwrites changes)

Attributes:

customer_key (INT, PRIMARY KEY, AUTO_INCREMENT): Surrogate key
customer_id (VARCHAR(20)): Natural key from source system
customer_name (VARCHAR(100)): Full name of the customer
city (VARCHAR(50)): Customer's city
state (VARCHAR(50)): Customer's state
customer_segment (VARCHAR(20)): Segment classification (High Value, Medium Value, Low Value)
Purpose: Enables customer segmentation analysis, geographic analysis, and customer behavior tracking.

Section 2: Design Decisions
Granularity Choice - Transaction Line-Item Level: I chose the transaction line-item level as the grain because it provides the most detailed view of sales data. This granularity allows us to analyze individual product performance within orders, calculate accurate product-level metrics, and aggregate data flexibly to any higher level (order, daily, monthly, etc.). It supports questions like "Which products are frequently bought together?" and "What is the average quantity per product per order?"

Surrogate Keys vs Natural Keys: I used surrogate keys (auto-incrementing integers) instead of natural keys for several reasons. First, surrogate keys are smaller and more efficient for indexing and joins, improving query performance. Second, they provide independence from source system changes—if a product ID format changes in the operational system, the data warehouse remains unaffected. Third, they simplify handling of slowly changing dimensions, as we can create new records with new surrogate keys while maintaining historical relationships. Finally, surrogate keys are guaranteed to be unique and immutable, preventing issues with composite keys or changing natural keys.

Drill-Down and Roll-Up Support: This star schema design inherently supports OLAP operations. The date dimension enables temporal drill-down (year → quarter → month → week → day) and roll-up operations. For example, users can start with annual sales, drill down to quarterly performance, then monthly trends, and finally daily transactions. Similarly, the product dimension supports drill-down from category to subcategory to individual products. The denormalized structure of dimensions ensures fast query performance for these operations without requiring multiple joins.

Section 3: Sample Data Flow
Source Transaction Example:
Order #101
Customer: John Doe (C015)
Product: Laptop (P007)
Quantity: 2
Unit Price: ₹50,000
Order Date: 2024-01-15
Total: ₹100,000
Transformation to Data Warehouse:
fact_sales record:

{
  sale_key: 1,
  date_key: 20240115,
  product_key: 5,
  customer_key: 12,
  quantity_sold: 2,
  unit_price: 50000.00,
  discount_amount: 0.00,
  total_amount: 100000.00
}
dim_date record:

{
  date_key: 20240115,
  full_date: '2024-01-15',
  day_of_week: 'Monday',
  day_of_month: 15,
  month: 1,
  month_name: 'January',
  quarter: 'Q1',
  year: 2024,
  is_weekend: FALSE
}
dim_product record:

{
  product_key: 5,
  product_id: 'P007',
  product_name: 'HP Laptop',
  category: 'Electronics',
  subcategory: 'Computers',
  unit_price: 52999.00
}
dim_customer record:

{
  customer_key: 12,
  customer_id: 'C015',
  customer_name: 'John Doe',
  city: 'Mumbai',
  state: 'Maharashtra',
  customer_segment: 'High Value'
}
Data Flow Process:

Extract order data from operational database (fleximart)
Look up or create date dimension record for 2024-01-15
Look up or create product dimension record for P007
Look up or create customer dimension record for C015
Insert fact record with foreign keys pointing to dimension records
The star schema now enables queries like "Total sales in January 2024 for Electronics category in Mumbai"
