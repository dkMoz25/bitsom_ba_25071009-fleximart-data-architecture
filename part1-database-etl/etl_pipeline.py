
import pandas as pd
import mysql.connector
from mysql.connector import Error
import re
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class FlexiMartETL:
    def __init__(self, host, user, password, database):
        self.host = host
        self.user = user
        self.password = password
        self.database = database
        self.connection = None
        self.quality_report = {
            'customers': {'processed': 0, 'duplicates': 0, 'missing_values': 0, 'loaded': 0},
            'products': {'processed': 0, 'duplicates': 0, 'missing_values': 0, 'loaded': 0},
            'sales': {'processed': 0, 'duplicates': 0, 'missing_values': 0, 'loaded': 0}
        }
    
    def connect_db(self):
        """Establish database connection"""
        try:
            self.connection = mysql.connector.connect(
                host=self.host,
                user=self.user,
                password=self.password,
                database=self.database
            )
            logging.info("Database connection established successfully")
        except Error as e:
            logging.error(f"Error connecting to database: {e}")
            raise
    
    def standardize_phone(self, phone):
        """Standardize phone format to +91-XXXXXXXXXX"""
        if pd.isna(phone):
            return None
        phone = str(phone).strip()
        # Remove all non-digit characters
        digits = re.sub(r'\D', '', phone)
        # Take last 10 digits
        if len(digits) >= 10:
            digits = digits[-10:]
            return f"+91-{digits}"
        return None
    
    def standardize_date(self, date_str):
        """Convert various date formats to YYYY-MM-DD"""
        if pd.isna(date_str):
            return None
        date_str = str(date_str).strip()
        
        # Try different date formats
        formats = ['%Y-%m-%d', '%d/%m/%Y', '%m-%d-%Y', '%d-%m-%Y', '%m/%d/%Y']
        for fmt in formats:
            try:
                return datetime.strptime(date_str, fmt).strftime('%Y-%m-%d')
            except ValueError:
                continue
        return None
    
    def standardize_category(self, category):
        """Standardize category names to title case"""
        if pd.isna(category):
            return None
        return category.strip().title()
    
    def extract_customers(self, filepath):
        """Extract customer data from CSV"""
        logging.info("Extracting customer data...")
        df = pd.read_csv(filepath)
        self.quality_report['customers']['processed'] = len(df)
        return df
    
    def transform_customers(self, df):
        """Transform customer data"""
        logging.info("Transforming customer data...")
        
        # Remove duplicates
        initial_count = len(df)
        df = df.drop_duplicates(subset=['customer_id'], keep='first')
        self.quality_report['customers']['duplicates'] = initial_count - len(df)
        
        # Handle missing emails - drop rows with missing emails
        missing_emails = df['email'].isna().sum()
        df = df.dropna(subset=['email'])
        self.quality_report['customers']['missing_values'] += missing_emails
        
        # Standardize phone formats
        df['phone'] = df['phone'].apply(self.standardize_phone)
        
        # Standardize city names
        df['city'] = df['city'].str.strip().str.title()
        
        # Standardize dates
        df['registration_date'] = df['registration_date'].apply(self.standardize_date)
        
        # Strip whitespace from names
        df['first_name'] = df['first_name'].str.strip()
        df['last_name'] = df['last_name'].str.strip()
        df['email'] = df['email'].str.strip().str.lower()
        
        return df
    
    def extract_products(self, filepath):
        """Extract product data from CSV"""
        logging.info("Extracting product data...")
        df = pd.read_csv(filepath)
        self.quality_report['products']['processed'] = len(df)
        return df
    
    def transform_products(self, df):
        """Transform product data"""
        logging.info("Transforming product data...")
        
        # Remove duplicates
        initial_count = len(df)
        df = df.drop_duplicates(subset=['product_id'], keep='first')
        self.quality_report['products']['duplicates'] = initial_count - len(df)
        
        # Handle missing prices - fill with median price by category
        missing_prices = df['price'].isna().sum()
        for category in df['category'].unique():
            median_price = df[df['category'] == category]['price'].median()
            df.loc[(df['category'] == category) & (df['price'].isna()), 'price'] = median_price
        self.quality_report['products']['missing_values'] += missing_prices
        
        # Handle missing stock - fill with 0
        missing_stock = df['stock_quantity'].isna().sum()
        df['stock_quantity'] = df['stock_quantity'].fillna(0).astype(int)
        self.quality_report['products']['missing_values'] += missing_stock
        
        # Standardize category names
        df['category'] = df['category'].apply(self.standardize_category)
        
        # Strip whitespace from product names
        df['product_name'] = df['product_name'].str.strip()
        
        return df
    
    def extract_sales(self, filepath):
        """Extract sales data from CSV"""
        logging.info("Extracting sales data...")
        df = pd.read_csv(filepath)
        self.quality_report['sales']['processed'] = len(df)
        return df
    
    def transform_sales(self, df):
        """Transform sales data"""
        logging.info("Transforming sales data...")
        
        # Remove duplicates
        initial_count = len(df)
        df = df.drop_duplicates(subset=['transaction_id'], keep='first')
        self.quality_report['sales']['duplicates'] = initial_count - len(df)
        
        # Handle missing customer_ids and product_ids - drop these rows
        missing_customers = df['customer_id'].isna().sum()
        missing_products = df['product_id'].isna().sum()
        df = df.dropna(subset=['customer_id', 'product_id'])
        self.quality_report['sales']['missing_values'] += (missing_customers + missing_products)
        
        # Standardize dates
        df['transaction_date'] = df['transaction_date'].apply(self.standardize_date)
        
        # Calculate total amount
        df['total_amount'] = df['quantity'] * df['unit_price']
        
        return df
    
    def load_customers(self, df):
        """Load customer data into database"""
        logging.info("Loading customer data...")
        cursor = self.connection.cursor()
        
        insert_query = """
        INSERT INTO customers (first_name, last_name, email, phone, city, registration_date)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        
        loaded = 0
        for _, row in df.iterrows():
            try:
                cursor.execute(insert_query, (
                    row['first_name'],
                    row['last_name'],
                    row['email'],
                    row['phone'],
                    row['city'],
                    row['registration_date']
                ))
                loaded += 1
            except Error as e:
                logging.error(f"Error inserting customer {row['customer_id']}: {e}")
        
        self.connection.commit()
        self.quality_report['customers']['loaded'] = loaded
        logging.info(f"Loaded {loaded} customers successfully")
    
    def load_products(self, df):
        """Load product data into database"""
        logging.info("Loading product data...")
        cursor = self.connection.cursor()
        
        insert_query = """
        INSERT INTO products (product_name, category, price, stock_quantity)
        VALUES (%s, %s, %s, %s)
        """
        
        loaded = 0
        for _, row in df.iterrows():
            try:
                cursor.execute(insert_query, (
                    row['product_name'],
                    row['category'],
                    row['price'],
                    row['stock_quantity']
                ))
                loaded += 1
            except Error as e:
                logging.error(f"Error inserting product {row['product_id']}: {e}")
        
        self.connection.commit()
        self.quality_report['products']['loaded'] = loaded
        logging.info(f"Loaded {loaded} products successfully")
    
    def load_sales(self, df, customer_mapping, product_mapping):
        """Load sales data into orders and order_items tables"""
        logging.info("Loading sales data...")
        cursor = self.connection.cursor()
        
        # Group by transaction to create orders
        loaded = 0
        for _, row in df.iterrows():
            try:
                # Get database IDs
                customer_db_id = customer_mapping.get(row['customer_id'])
                product_db_id = product_mapping.get(row['product_id'])
                
                if not customer_db_id or not product_db_id:
                    continue
                
                # Insert order
                order_query = """
                INSERT INTO orders (customer_id, order_date, total_amount, status)
                VALUES (%s, %s, %s, %s)
                """
                cursor.execute(order_query, (
                    customer_db_id,
                    row['transaction_date'],
                    row['total_amount'],
                    row['status']
                ))
                order_id = cursor.lastrowid
                
                # Insert order item
                item_query = """
                INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
                VALUES (%s, %s, %s, %s, %s)
                """
                cursor.execute(item_query, (
                    order_id,
                    product_db_id,
                    row['quantity'],
                    row['unit_price'],
                    row['total_amount']
                ))
                loaded += 1
            except Error as e:
                logging.error(f"Error inserting sale {row['transaction_id']}: {e}")
        
        self.connection.commit()
        self.quality_report['sales']['loaded'] = loaded
        logging.info(f"Loaded {loaded} sales transactions successfully")
    
    def get_customer_mapping(self, original_df):
        """Get mapping between original customer_id and database customer_id"""
        cursor = self.connection.cursor()
        cursor.execute("SELECT customer_id, email FROM customers")
        db_customers = cursor.fetchall()
        
        mapping = {}
        for db_id, email in db_customers:
            original_id = original_df[original_df['email'] == email]['customer_id'].values
            if len(original_id) > 0:
                mapping[original_id[0]] = db_id
        return mapping
    
    def get_product_mapping(self, original_df):
        """Get mapping between original product_id and database product_id"""
        cursor = self.connection.cursor()
        cursor.execute("SELECT product_id, product_name FROM products")
        db_products = cursor.fetchall()
        
        mapping = {}
        for db_id, name in db_products:
            original_id = original_df[original_df['product_name'] == name]['product_id'].values
            if len(original_id) > 0:
                mapping[original_id[0]] = db_id
        return mapping
    
    def generate_quality_report(self):
        """Generate data quality report"""
        logging.info("Generating data quality report...")
        
        report = "=" * 60 + "
"
        report += "DATA QUALITY REPORT - FlexiMart ETL Pipeline
"
        report += "=" * 60 + "

"
        
        for table, stats in self.quality_report.items():
            report += f"{table.upper()} TABLE:
"
            report += f"  Records Processed: {stats['processed']}
"
            report += f"  Duplicates Removed: {stats['duplicates']}
"
            report += f"  Missing Values Handled: {stats['missing_values']}
"
            report += f"  Records Loaded Successfully: {stats['loaded']}
"
            report += f"  Success Rate: {(stats['loaded']/stats['processed']*100):.2f}%

"
        
        with open('data_quality_report.txt', 'w') as f:
            f.write(report)
        
        logging.info("Quality report saved to data_quality_report.txt")
    
    def run_etl(self, customers_file, products_file, sales_file):
        """Run complete ETL pipeline"""
        try:
            self.connect_db()
            
            # Extract
            customers_df = self.extract_customers(customers_file)
            products_df = self.extract_products(products_file)
            sales_df = self.extract_sales(sales_file)
            
            # Transform
            customers_clean = self.transform_customers(customers_df)
            products_clean = self.transform_products(products_df)
            sales_clean = self.transform_sales(sales_df)
            
            # Load
            self.load_customers(customers_clean)
            self.load_products(products_clean)
            
            # Get mappings for foreign keys
            customer_mapping = self.get_customer_mapping(customers_df)
            product_mapping = self.get_product_mapping(products_df)
            
            self.load_sales(sales_clean, customer_mapping, product_mapping)
            
            # Generate report
            self.generate_quality_report()
            
            logging.info("ETL pipeline completed successfully!")
            
        except Exception as e:
            logging.error(f"ETL pipeline failed: {e}")
            raise
        finally:
            if self.connection and self.connection.is_connected():
                self.connection.close()
                logging.info("Database connection closed")

# Main execution
if __name__ == "__main__":
    etl = FlexiMartETL(
        host='localhost',
        user='root',
        password='your_password',
        database='fleximart'
    )
    
    etl.run_etl(
        customers_file='data/customers_raw.csv',
        products_file='data/products_raw.csv',
        sales_file='data/sales_raw.csv'
    )

