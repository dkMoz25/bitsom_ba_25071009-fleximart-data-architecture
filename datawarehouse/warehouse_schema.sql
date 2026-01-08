
-- Database: fleximart_dw
-- Star Schema Implementation for FlexiMart Data Warehouse

-- Create Date Dimension
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day_of_week VARCHAR(10),
    day_of_month INT,
    month INT,
    month_name VARCHAR(10),
    quarter VARCHAR(2),
    year INT,
    is_weekend BOOLEAN
);

-- Create Product Dimension
CREATE TABLE dim_product (
    product_key INT PRIMARY KEY AUTO_INCREMENT,
    product_id VARCHAR(20),
    product_name VARCHAR(100),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    unit_price DECIMAL(10,2)
);

-- Create Customer Dimension
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    customer_segment VARCHAR(20)
);

-- Create Sales Fact Table
CREATE TABLE fact_sales (
    sale_key INT PRIMARY KEY AUTO_INCREMENT,
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    quantity_sold INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key)
);

-- Create indexes for better query performance
CREATE INDEX idx_fact_date ON fact_sales(date_key);
CREATE INDEX idx_fact_product ON fact_sales(product_key);
CREATE INDEX idx_fact_customer ON fact_sales(customer_key);
CREATE INDEX idx_date_year_month ON dim_date(year, month);
CREATE INDEX idx_product_category ON dim_product(category);
CREATE INDEX idx_customer_city ON dim_customer(city);


