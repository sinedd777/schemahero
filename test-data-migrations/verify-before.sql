-- Verification script: BEFORE migrations
-- This shows the initial state of data before any migrations

\echo '🔍 BEFORE MIGRATIONS - Data State Verification'
\echo '================================================'

\echo ''
\echo '👥 CUSTOMERS - Data Quality Issues:'
\echo '-----------------------------------'
SELECT 
    'NULL status count' as issue,
    COUNT(*) as count
FROM customers WHERE status IS NULL
UNION ALL
SELECT 
    'NULL region count',
    COUNT(*) 
FROM customers WHERE region IS NULL
UNION ALL
SELECT 
    'NULL full_name count',
    COUNT(*) 
FROM customers WHERE full_name IS NULL
UNION ALL
SELECT 
    'Mixed case emails',
    COUNT(*) 
FROM customers WHERE email != LOWER(email)
UNION ALL
SELECT 
    'NULL notification_enabled',
    COUNT(*) 
FROM customers WHERE notification_enabled IS NULL;

\echo ''
\echo '🛍️ PRODUCTS - Data Quality Issues:'
\echo '----------------------------------'
SELECT 
    'NULL status count' as issue,
    COUNT(*) as count
FROM products WHERE status IS NULL
UNION ALL
SELECT 
    'Old SKU format (OLD-)',
    COUNT(*) 
FROM products WHERE sku LIKE 'OLD-%'
UNION ALL
SELECT 
    'Old SKU format (old-)',
    COUNT(*) 
FROM products WHERE sku LIKE 'old-%'
UNION ALL
SELECT 
    'NULL price_dollars',
    COUNT(*) 
FROM products WHERE price_dollars IS NULL AND price_cents IS NOT NULL;

\echo ''
\echo '👨‍💼 EMPLOYEES - Data Quality Issues:'
\echo '------------------------------------'
SELECT 
    'NULL status count' as issue,
    COUNT(*) as count
FROM employees WHERE status IS NULL
UNION ALL
SELECT 
    'NULL timezone count',
    COUNT(*) 
FROM employees WHERE timezone IS NULL
UNION ALL
SELECT 
    'NULL full_name count',
    COUNT(*) 
FROM employees WHERE full_name IS NULL
UNION ALL
SELECT 
    'Old employee_id format',
    COUNT(*) 
FROM employees WHERE employee_id LIKE 'OLD-%' OR employee_id LIKE 'old-%'
UNION ALL
SELECT 
    'NULL salary_dollars',
    COUNT(*) 
FROM employees WHERE salary_dollars IS NULL AND salary_cents IS NOT NULL;

\echo ''
\echo '🛒 ORDERS - Data Quality Issues:'
\echo '-------------------------------'
SELECT 
    'NULL status count' as issue,
    COUNT(*) as count
FROM orders WHERE status IS NULL
UNION ALL
SELECT 
    'NULL total_dollars',
    COUNT(*) 
FROM orders WHERE total_dollars IS NULL AND total_cents IS NOT NULL
UNION ALL
SELECT 
    'NULL updated_at',
    COUNT(*) 
FROM orders WHERE updated_at IS NULL;

\echo ''
\echo '📦 ORDER ITEMS - Data Quality Issues:'
\echo '------------------------------------'
SELECT 
    'NULL unit_price_dollars' as issue,
    COUNT(*) as count
FROM order_items WHERE unit_price_dollars IS NULL AND unit_price_cents IS NOT NULL
UNION ALL
SELECT 
    'NULL total_dollars',
    COUNT(*) 
FROM order_items WHERE total_dollars IS NULL AND total_cents IS NOT NULL;

\echo ''
\echo '📊 Sample Data Preview:'
\echo '======================='

\echo ''
\echo 'Customers with issues:'
SELECT id, first_name, last_name, email, status, region, full_name
FROM customers 
WHERE status IS NULL OR region IS NULL OR full_name IS NULL OR email != LOWER(email)
ORDER BY id;

\echo ''
\echo 'Products with issues:'
SELECT id, name, sku, status, price_cents, price_dollars
FROM products 
WHERE status IS NULL OR sku LIKE 'OLD-%' OR sku LIKE 'old-%' OR price_dollars IS NULL
ORDER BY id;

\echo ''
\echo 'Employees with issues:'
SELECT id, employee_id, first_name, last_name, status, timezone, salary_cents, salary_dollars
FROM employees 
WHERE status IS NULL OR timezone IS NULL OR employee_id LIKE 'OLD-%' OR employee_id LIKE 'old-%'
ORDER BY id;

\echo ''
\echo '💡 These issues will be fixed by the data migrations!'
