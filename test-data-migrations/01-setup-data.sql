-- Initial test data setup for SchemaHero data migration testing
-- This creates realistic test data with various edge cases

\echo '🌱 Inserting test data...'

-- Insert customers with mixed data quality issues
INSERT INTO customers (first_name, last_name, email, phone, created_at, status, region, loyalty_points, timezone) VALUES
-- Good data
('John', 'Doe', 'john.doe@example.com', '555-0101', '2023-01-15 10:30:00', 'active', 'us-east-1', 150, 'UTC'),
('Jane', 'Smith', 'jane.smith@example.com', '555-0102', '2023-02-20 14:45:00', 'active', 'us-west-2', 300, 'UTC'),
('Bob', 'Johnson', 'bob.johnson@example.com', '555-0103', '2023-03-10 09:15:00', 'active', 'eu-west-1', 75, 'UTC'),

-- Data that needs fixing
('Alice', 'Brown', 'ALICE.BROWN@EXAMPLE.COM', '555-0104', '2023-01-25 11:20:00', NULL, NULL, 0, NULL),
('Charlie', 'Wilson', 'charlie.wilson@EXAMPLE.com', '555-0105', '2023-02-28 16:30:00', NULL, NULL, 50, NULL),
('Diana', NULL, 'diana@example.com', '555-0106', '2023-03-05 08:45:00', 'inactive', NULL, 0, NULL),
(NULL, 'Miller', 'miller@example.com', '555-0107', '2023-01-12 13:25:00', NULL, 'us-central', 25, 'UTC'),

-- Edge cases
('Emma', 'Davis', 'emma.davis@example.com', NULL, '2023-01-01 00:00:00', 'pending', 'ca-central-1', 500, 'UTC'),
('Frank', 'Taylor', '', '555-0109', '2023-02-14 12:00:00', 'suspended', 'ap-southeast-1', -10, 'UTC');

-- Insert products with pricing issues
INSERT INTO products (name, description, price_cents, category, sku, status, created_at) VALUES
-- Good data
('Laptop Pro', 'High-performance laptop', 149999, 'electronics', 'ELEC-001', 'active', '2023-01-10 09:00:00'),
('Wireless Mouse', 'Ergonomic wireless mouse', 2999, 'electronics', 'ELEC-002', 'active', '2023-01-15 10:00:00'),
('Office Chair', 'Comfortable ergonomic chair', 29999, 'furniture', 'FURN-001', 'active', '2023-01-20 11:00:00'),

-- Data that needs conversion/fixing
('Smartphone', 'Latest model smartphone', 79999, 'electronics', 'OLD-ELEC-003', NULL, '2023-02-01 14:00:00'),
('Coffee Mug', 'Ceramic coffee mug', 1499, 'kitchen', 'OLD-KITCH-001', NULL, '2023-02-05 15:00:00'),
('Desk Lamp', 'LED desk lamp', 4999, 'electronics', 'old-elec-004', 'discontinued', '2023-01-25 13:00:00'),

-- Edge cases  
('Mystery Item', '', 0, '', '', NULL, '2023-03-01 00:00:00'),
('Expensive Item', 'Very expensive item', 999999, 'luxury', 'LUX-001', 'active', '2023-01-05 16:00:00');

-- Insert employees with salary data
INSERT INTO employees (employee_id, first_name, last_name, email, department, hire_date, salary_cents, status, timezone) VALUES
('EMP001', 'Sarah', 'Connor', 'sarah.connor@company.com', 'engineering', '2022-01-15 09:00:00', 8500000, 'active', 'UTC'),
('EMP002', 'John', 'Connor', 'john.connor@company.com', 'engineering', '2022-03-20 09:00:00', 7500000, 'active', 'UTC'),
('EMP003', 'Kyle', 'Reese', 'kyle.reese@company.com', 'security', '2022-06-01 09:00:00', 6500000, NULL, NULL),
('OLD-EMP-004', 'Ellen', 'Ripley', 'ellen.ripley@company.com', 'operations', '2021-12-01 09:00:00', 7000000, NULL, NULL),
('old-emp-005', 'Dallas', 'Kane', 'dallas.kane@company.com', 'management', '2021-08-15 09:00:00', 9500000, 'active', 'UTC');

-- Insert orders with various statuses
INSERT INTO orders (order_number, customer_id, total_cents, tax_cents, status, created_at) VALUES
('ORD-2023-001', 1, 152999, 12240, 'completed', '2023-03-01 10:30:00'),
('ORD-2023-002', 2, 32998, 2640, 'completed', '2023-03-02 14:20:00'),
('ORD-2023-003', 3, 4999, 400, 'pending', '2023-03-03 09:15:00'),
('ORD-2023-004', 4, 79999, 6400, NULL, '2023-03-04 16:45:00'),
('ORD-2023-005', 5, 1499, 120, NULL, '2023-03-05 11:30:00');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price_cents, total_cents) VALUES
(1, 1, 1, 149999, 149999),
(1, 2, 1, 2999, 2999),
(2, 2, 1, 2999, 2999),
(2, 3, 1, 29999, 29999),
(3, 6, 1, 4999, 4999),
(4, 4, 1, 79999, 79999),
(5, 5, 1, 1499, 1499);

\echo '✅ Test data inserted successfully!'

-- Show initial data summary
\echo ''
\echo '📊 Data Summary:'
SELECT 'customers' as table_name, count(*) as row_count FROM customers
UNION ALL
SELECT 'products', count(*) FROM products  
UNION ALL
SELECT 'employees', count(*) FROM employees
UNION ALL
SELECT 'orders', count(*) FROM orders
UNION ALL
SELECT 'order_items', count(*) FROM order_items;

\echo ''
\echo '🔍 Data Quality Issues to Fix:'
\echo 'Customers with NULL status:' 
SELECT count(*) FROM customers WHERE status IS NULL;

\echo 'Customers with NULL full_name:'
SELECT count(*) FROM customers WHERE full_name IS NULL;

\echo 'Products with NULL status:'
SELECT count(*) FROM products WHERE status IS NULL;

\echo 'Products with old SKU format:'
SELECT count(*) FROM products WHERE sku LIKE 'OLD-%' OR sku LIKE 'old-%';

\echo ''
\echo '💰 Pricing data (cents) to convert to dollars:'
SELECT 'Products with price_cents but NULL price_dollars' as issue, count(*) 
FROM products WHERE price_cents IS NOT NULL AND price_dollars IS NULL;
