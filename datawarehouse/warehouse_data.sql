
-- Sample Data for FlexiMart Data Warehouse
-- warehouse_data.sql

-- Populate Date Dimension (January-February 2024)
INSERT INTO dim_date (date_key, full_date, day_of_week, day_of_month, month, month_name, quarter, year, is_weekend) VALUES
(20240101, '2024-01-01', 'Monday', 1, 1, 'January', 'Q1', 2024, FALSE),
(20240102, '2024-01-02', 'Tuesday', 2, 1, 'January', 'Q1', 2024, FALSE),
(20240103, '2024-01-03', 'Wednesday', 3, 1, 'January', 'Q1', 2024, FALSE),
(20240104, '2024-01-04', 'Thursday', 4, 1, 'January', 'Q1', 2024, FALSE),
(20240105, '2024-01-05', 'Friday', 5, 1, 'January', 'Q1', 2024, FALSE),
(20240106, '2024-01-06', 'Saturday', 6, 1, 'January', 'Q1', 2024, TRUE),
(20240107, '2024-01-07', 'Sunday', 7, 1, 'January', 'Q1', 2024, TRUE),
(20240108, '2024-01-08', 'Monday', 8, 1, 'January', 'Q1', 2024, FALSE),
(20240109, '2024-01-09', 'Tuesday', 9, 1, 'January', 'Q1', 2024, FALSE),
(20240110, '2024-01-10', 'Wednesday', 10, 1, 'January', 'Q1', 2024, FALSE),
(20240111, '2024-01-11', 'Thursday', 11, 1, 'January', 'Q1', 2024, FALSE),
(20240112, '2024-01-12', 'Friday', 12, 1, 'January', 'Q1', 2024, FALSE),
(20240113, '2024-01-13', 'Saturday', 13, 1, 'January', 'Q1', 2024, TRUE),
(20240114, '2024-01-14', 'Sunday', 14, 1, 'January', 'Q1', 2024, TRUE),
(20240115, '2024-01-15', 'Monday', 15, 1, 'January', 'Q1', 2024, FALSE),
(20240116, '2024-01-16', 'Tuesday', 16, 1, 'January', 'Q1', 2024, FALSE),
(20240117, '2024-01-17', 'Wednesday', 17, 1, 'January', 'Q1', 2024, FALSE),
(20240118, '2024-01-18', 'Thursday', 18, 1, 'January', 'Q1', 2024, FALSE),
(20240119, '2024-01-19', 'Friday', 19, 1, 'January', 'Q1', 2024, FALSE),
(20240120, '2024-01-20', 'Saturday', 20, 1, 'January', 'Q1', 2024, TRUE),
(20240121, '2024-01-21', 'Sunday', 21, 1, 'January', 'Q1', 2024, TRUE),
(20240122, '2024-01-22', 'Monday', 22, 1, 'January', 'Q1', 2024, FALSE),
(20240123, '2024-01-23', 'Tuesday', 23, 1, 'January', 'Q1', 2024, FALSE),
(20240124, '2024-01-24', 'Wednesday', 24, 1, 'January', 'Q1', 2024, FALSE),
(20240125, '2024-01-25', 'Thursday', 25, 1, 'January', 'Q1', 2024, FALSE),
(20240126, '2024-01-26', 'Friday', 26, 1, 'January', 'Q1', 2024, FALSE),
(20240127, '2024-01-27', 'Saturday', 27, 1, 'January', 'Q1', 2024, TRUE),
(20240128, '2024-01-28', 'Sunday', 28, 1, 'January', 'Q1', 2024, TRUE),
(20240129, '2024-01-29', 'Monday', 29, 1, 'January', 'Q1', 2024, FALSE),
(20240130, '2024-01-30', 'Tuesday', 30, 1, 'January', 'Q1', 2024, FALSE),
(20240131, '2024-01-31', 'Wednesday', 31, 1, 'January', 'Q1', 2024, FALSE),
(20240201, '2024-02-01', 'Thursday', 1, 2, 'February', 'Q1', 2024, FALSE),
(20240202, '2024-02-02', 'Friday', 2, 2, 'February', 'Q1', 2024, FALSE),
(20240203, '2024-02-03', 'Saturday', 3, 2, 'February', 'Q1', 2024, TRUE),
(20240204, '2024-02-04', 'Sunday', 4, 2, 'February', 'Q1', 2024, TRUE);

-- Populate Product Dimension (15 products across 3 categories)
INSERT INTO dim_product (product_id, product_name, category, subcategory, unit_price) VALUES
('P001', 'Samsung Galaxy S21', 'Electronics', 'Smartphones', 45999.00),
('P002', 'Apple iPhone 13', 'Electronics', 'Smartphones', 69999.00),
('P003', 'OnePlus Nord', 'Electronics', 'Smartphones', 26999.00),
('P004', 'Apple MacBook Pro', 'Electronics', 'Laptops', 189999.00),
('P005', 'HP Laptop', 'Electronics', 'Laptops', 52999.00),
('P006', 'Dell Monitor 24inch', 'Electronics', 'Accessories', 12999.00),
('P007', 'Sony Headphones', 'Electronics', 'Accessories', 1999.00),
('P008', 'Samsung TV 43inch', 'Electronics', 'Television', 32999.00),
('P009', 'Levis Jeans', 'Fashion', 'Clothing', 2999.00),
('P010', 'Nike Running Shoes', 'Fashion', 'Footwear', 3499.00),
('P011', 'Adidas T-Shirt', 'Fashion', 'Clothing', 1299.00),
('P012', 'Puma Sneakers', 'Fashion', 'Footwear', 4599.00),
('P013', 'Organic Almonds 1kg', 'Groceries', 'Dry Fruits', 899.00),
('P014', 'Basmati Rice 5kg', 'Groceries', 'Staples', 650.00),
('P015', 'Organic Honey 500g', 'Groceries', 'Health Foods', 450.00);

-- Populate Customer Dimension (12 customers across 4 cities)
INSERT INTO dim_customer (customer_id, customer_name, city, state, customer_segment) VALUES
('C001', 'Rahul Sharma', 'Bangalore', 'Karnataka', 'High Value'),
('C002', 'Priya Patel', 'Mumbai', 'Maharashtra', 'High Value'),
('C003', 'Sneha Reddy', 'Hyderabad', 'Telangana', 'Medium Value'),
('C004', 'Vikram Singh', 'Chennai', 'Tamil Nadu', 'Medium Value'),
('C005', 'Anjali Mehta', 'Bangalore', 'Karnataka', 'High Value'),
('C006', 'Karthik Nair', 'Mumbai', 'Maharashtra', 'Medium Value'),
('C007', 'Deepa Gupta', 'Delhi', 'Delhi', 'Low Value'),
('C008', 'Arjun Rao', 'Hyderabad', 'Telangana', 'High Value'),
('C009', 'Neha Shah', 'Mumbai', 'Maharashtra', 'Medium Value'),
('C010', 'Manish Joshi', 'Bangalore', 'Karnataka', 'Low Value'),
('C011', 'Rajesh Kumar', 'Delhi', 'Delhi', 'Medium Value'),
('C012', 'Kavya Menon', 'Chennai', 'Tamil Nadu', 'Low Value');

-- Populate Fact Sales (40 transactions with realistic patterns)
INSERT INTO fact_sales (date_key, product_key, customer_key, quantity_sold, unit_price, discount_amount, total_amount) VALUES
-- Week 1 (Jan 1-7) - Lower sales
(20240102, 1, 1, 1, 45999.00, 0, 45999.00),
(20240103, 9, 2, 2, 2999.00, 300, 5698.00),
(20240104, 13, 3, 3, 899.00, 0, 2697.00),
(20240105, 7, 4, 2, 1999.00, 0, 3998.00),
(20240106, 10, 5, 1, 3499.00, 0, 3499.00),
(20240107, 11, 6, 3, 1299.00, 0, 3897.00),
-- Week 2 (Jan 8-14) - Moderate sales
(20240108, 5, 1, 1, 52999.00, 2000, 50999.00),
(20240109, 14, 7, 5, 650.00, 0, 3250.00),
(20240110, 2, 8, 1, 69999.00, 5000, 64999.00),
(20240111, 12, 2, 1, 4599.00, 0, 4599.00),
(20240112, 15, 9, 4, 450.00, 0, 1800.00),
(20240113, 8, 3, 1, 32999.00, 3000, 29999.00),
(20240114, 6, 10, 1, 12999.00, 1000, 11999.00),
-- Week 3 (Jan 15-21) - Higher sales
(20240115, 4, 5, 1, 189999.00, 10000, 179999.00),
(20240116, 9, 11, 2, 2999.00, 0, 5998.00),
(20240117, 1, 12, 1, 45999.00, 2000, 43999.00),
(20240118, 10, 1, 2, 3499.00, 0, 6998.00),
(20240119, 7, 4, 3, 1999.00, 300, 5697.00),
(20240120, 3, 6, 1, 26999.00, 1000, 25999.00),
(20240121, 11, 8, 4, 1299.00, 0, 5196.00),
-- Week 4 (Jan 22-28) - Peak sales
(20240122, 2, 2, 1, 69999.00, 0, 69999.00),
(20240123, 13, 3, 5, 899.00, 200, 4295.00),
(20240124, 5, 9, 1, 52999.00, 3000, 49999.00),
(20240125, 12, 5, 1, 4599.00, 0, 4599.00),
(20240126, 14, 7, 10, 650.00, 0, 6500.00),
(20240127, 8, 1, 1, 32999.00, 2000, 30999.00),
(20240128, 6, 10, 2, 12999.00, 1500, 24498.00),
-- Week 5 (Jan 29-31) - End of month
(20240129, 15, 11, 6, 450.00, 0, 2700.00),
(20240130, 9, 12, 1, 2999.00, 0, 2999.00),
(20240131, 1, 8, 1, 45999.00, 3000, 42999.00),
-- February (Feb 1-4) - New month start
(20240201, 4, 5, 1, 189999.00, 15000, 174999.00),
(20240201, 10, 2, 1, 3499.00, 0, 3499.00),
(20240202, 7, 3, 2, 1999.00, 0, 3998.00),
(20240202, 11, 6, 5, 1299.00, 300, 6195.00),
(20240203, 3, 1, 1, 26999.00, 2000, 24999.00),
(20240203, 13, 4, 4, 899.00, 0, 3596.00),
(20240204, 2, 9, 1, 69999.00, 5000, 64999.00),
(20240204, 12, 7, 1, 4599.00, 0, 4599.00),
(20240204, 14, 11, 8, 650.00, 0, 5200.00),
(20240204, 8, 12, 1, 32999.00, 0, 32999.00);

-- Verify data load
SELECT 'Date Dimension' AS table_name, COUNT(*) AS record_count FROM dim_date
UNION ALL
SELECT 'Product Dimension', COUNT(*) FROM dim_product
UNION ALL
SELECT 'Customer Dimension', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'Sales Fact', COUNT(*) FROM fact_sales;

