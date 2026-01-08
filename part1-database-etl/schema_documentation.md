Task 1.2: Schema Documentation
FlexiMart Database Schema Documentation
Entity-Relationship Description

ENTITY: customers
Purpose: Stores customer information for FlexiMart's e-commerce platform

Attributes:
customer_id (INT, PRIMARY KEY, AUTO_INCREMENT): Unique identifier for each customer
first_name (VARCHAR(50), NOT NULL): Customer's first name
last_name (VARCHAR(50), NOT NULL): Customer's last name
email (VARCHAR(100), UNIQUE, NOT NULL): Customer's email address (unique identifier for login)
phone (VARCHAR(20)): Customer's contact phone number
city (VARCHAR(50)): Customer's city of residence
registration_date (DATE): Date when customer registered on the platform

Relationships:
One customer can place MANY orders (1:M with orders table via customer_id)

ENTITY: products
Purpose: Stores product catalog information

Attributes:
product_id (INT, PRIMARY KEY, AUTO_INCREMENT): Unique identifier for each product
product_name (VARCHAR(100), NOT NULL): Name of the product
category (VARCHAR(50), NOT NULL): Product category (e.g., Electronics, Fashion, Groceries)
price (DECIMAL(10,2), NOT NULL): Current selling price of the product
stock_quantity (INT, DEFAULT 0): Available stock quantity
Relationships:
One product can appear in MANY order items (1:M with order_items table via product_id)

ENTITY: orders
Purpose: Stores order header information

Attributes:
order_id (INT, PRIMARY KEY, AUTO_INCREMENT): Unique identifier for each order
customer_id (INT, NOT NULL, FOREIGN KEY): References customer who placed the order
order_date (DATE, NOT NULL): Date when order was placed
total_amount (DECIMAL(10,2), NOT NULL): Total order value
status (VARCHAR(20), DEFAULT 'Pending'): Order status (Pending, Completed, Cancelled)
Relationships:

MANY orders belong to ONE customer (M:1 with customers table via customer_id)
One order can have MANY order items (1:M with order_items table via order_id)
ENTITY: order_items
Purpose: Stores individual line items for each order
Attributes:
order_item_id (INT, PRIMARY KEY, AUTO_INCREMENT): Unique identifier for each order line item
order_id (INT, NOT NULL, FOREIGN KEY): References the parent order
product_id (INT, NOT NULL, FOREIGN KEY): References the product ordered
quantity (INT, NOT NULL): Quantity of product ordered
unit_price (DECIMAL(10,2), NOT NULL): Price per unit at time of order
subtotal (DECIMAL(10,2), NOT NULL): Line item total (quantity × unit_price)

Relationships:
MANY order items belong to ONE order (M:1 with orders table via order_id)
MANY order items reference ONE product (M:1 with products table via product_id)

Normalization Explanation (3NF)
This database design is in Third Normal Form (3NF) because it satisfies all requirements of 1NF, 2NF, and 3NF:
First Normal Form (1NF): All tables have atomic values (no repeating groups or arrays). Each column contains only single values, and each row is unique with a primary key.
Second Normal Form (2NF): All non-key attributes are fully functionally dependent on the primary key. There are no partial dependencies. For example, in the order_items table, both quantity and unit_price depend on the complete primary key (order_item_id), not just part of it.
Third Normal Form (3NF): There are no transitive dependencies. All non-key attributes depend only on the primary key, not on other non-key attributes.

Functional Dependencies:
customers: customer_id → first_name, last_name, email, phone, city, registration_date
products: product_id → product_name, category, price, stock_quantity
orders: order_id → customer_id, order_date, total_amount, status
order_items: order_item_id → order_id, product_id, quantity, unit_price, subtotal

Anomaly Prevention:
Update Anomaly: If we stored customer information with each order in a single table, updating a customer's phone number would require updating multiple rows. Our design prevents this by storing customer data once in the customers table.
Insert Anomaly: We can add new products to the catalog without requiring an order to exist. Similarly, we can register customers before they place any orders.
Delete Anomaly: If we delete an order, we don't lose customer or product information since they're stored in separate tables. The referential integrity is maintained through foreign keys.

