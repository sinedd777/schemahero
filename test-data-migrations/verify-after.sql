-- Verification script: AFTER migrations
-- This shows the final state of data after all migrations

\echo '✅ AFTER MIGRATIONS - Data State Verification'
\echo '============================================='

\echo ''
\echo '👥 CUSTOMERS - Fixed Issues:'
\echo '----------------------------'
SELECT 
    'NULL status count (should be 0)' as check_result,
    COUNT(*) as count,
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM customers WHERE status IS NULL
UNION ALL
SELECT 
    'NULL region count (should be 0)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM customers WHERE region IS NULL
UNION ALL
SELECT 
    'NULL full_name count (should be 0)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM customers WHERE full_name IS NULL
UNION ALL
SELECT 
    'Mixed case emails (should be 0)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM customers WHERE email != LOWER(email)
UNION ALL
SELECT 
    'Active customers with loyalty points',
    COUNT(*),
    CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM customers WHERE status = 'active' AND loyalty_points > 0;

\echo ''
\echo '🛍️ PRODUCTS - Fixed Issues:'
\echo '---------------------------'
SELECT 
    'NULL status count (should be 0)' as check_result,
    COUNT(*) as count,
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM products WHERE status IS NULL
UNION ALL
SELECT 
    'Old SKU format OLD- (should be 0)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM products WHERE sku LIKE 'OLD-%'
UNION ALL
SELECT 
    'Old SKU format old- (should be 0)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM products WHERE sku LIKE 'old-%'
UNION ALL
SELECT 
    'NULL price_dollars (should be 0)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM products WHERE price_dollars IS NULL AND price_cents IS NOT NULL
UNION ALL
SELECT 
    'Products with updated categories',
    COUNT(*),
    CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM products WHERE category IN ('premium', 'standard', 'basic', 'economy');

\echo ''
\echo '👨‍💼 EMPLOYEES - Fixed Issues:'
\echo '-----------------------------'
SELECT 
    'NULL status count (should be 0)' as check_result,
    COUNT(*) as count,
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM employees WHERE status IS NULL
UNION ALL
SELECT 
    'NULL timezone count (should be 0)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM employees WHERE timezone IS NULL
UNION ALL
SELECT 
    'NULL full_name count (should be 0)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM employees WHERE full_name IS NULL
UNION ALL
SELECT 
    'Old employee_id format (should be 0)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM employees WHERE employee_id LIKE 'OLD-%' OR employee_id LIKE 'old-%'
UNION ALL
SELECT 
    'NULL salary_dollars (should be 0)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM employees WHERE salary_dollars IS NULL AND salary_cents IS NOT NULL;

\echo ''
\echo '🛒 ORDERS - Fixed Issues:'
\echo '------------------------'
SELECT 
    'NULL status count (should be 0)' as check_result,
    COUNT(*) as count,
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM orders WHERE status IS NULL
UNION ALL
SELECT 
    'NULL total_dollars (should be 0)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM orders WHERE total_dollars IS NULL AND total_cents IS NOT NULL
UNION ALL
SELECT 
    'Completed orders with shipped_at',
    COUNT(*),
    CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM orders WHERE status = 'completed' AND shipped_at IS NOT NULL;

\echo ''
\echo '📦 ORDER ITEMS - Fixed Issues:'
\echo '-----------------------------'
SELECT 
    'NULL unit_price_dollars (should be 0)' as check_result,
    COUNT(*) as count,
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM order_items WHERE unit_price_dollars IS NULL AND unit_price_cents IS NOT NULL
UNION ALL
SELECT 
    'NULL total_dollars (should be 0)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM order_items WHERE total_dollars IS NULL AND total_cents IS NOT NULL;

\echo ''
\echo '📈 Business Logic Results:'
\echo '========================='

\echo ''
\echo 'Customer loyalty points distribution:'
SELECT 
    CASE 
        WHEN loyalty_points = 0 THEN '0 points'
        WHEN loyalty_points <= 100 THEN '1-100 points'
        WHEN loyalty_points <= 500 THEN '101-500 points'
        ELSE '500+ points'
    END as point_range,
    COUNT(*) as customer_count
FROM customers 
GROUP BY 
    CASE 
        WHEN loyalty_points = 0 THEN '0 points'
        WHEN loyalty_points <= 100 THEN '1-100 points' 
        WHEN loyalty_points <= 500 THEN '101-500 points'
        ELSE '500+ points'
    END
ORDER BY MIN(loyalty_points);

\echo ''
\echo 'Product category distribution:'
SELECT category, COUNT(*) as product_count, 
       ROUND(AVG(price_dollars), 2) as avg_price
FROM products 
WHERE category IS NOT NULL
GROUP BY category
ORDER BY avg_price DESC;

\echo ''
\echo 'Employee department distribution:'
SELECT department, COUNT(*) as employee_count,
       ROUND(AVG(salary_dollars), 2) as avg_salary
FROM employees 
WHERE department IS NOT NULL
GROUP BY department
ORDER BY avg_salary DESC;

\echo ''
\echo '📊 Sample Transformed Data:'
\echo '=========================='

\echo ''
\echo 'Customers (first 5):'
SELECT id, full_name, display_email, status, region, loyalty_points, 
       CASE WHEN last_login IS NOT NULL THEN 'Set' ELSE 'NULL' END as last_login_status
FROM customers 
ORDER BY id LIMIT 5;

\echo ''
\echo 'Products (first 5):'
SELECT id, name, sku, category, price_dollars, status
FROM products 
ORDER BY id LIMIT 5;

\echo ''
\echo 'Employees (first 5):'
SELECT id, employee_id, full_name, department, salary_dollars, status
FROM employees 
ORDER BY id LIMIT 5;

\echo ''
\echo '🎉 Migration verification complete!'
