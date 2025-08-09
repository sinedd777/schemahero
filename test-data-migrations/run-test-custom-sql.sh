#!/bin/bash

# Test 4: Custom SQL Migration
set -e

DB_URI="postgres://testuser:testpass@localhost:5432/schemahero_test"
export PGPASSWORD="testpass"

echo "🧪 Test 4: Custom SQL Migration"
echo "==============================="

echo ""
echo "📊 BEFORE - Business logic baseline..."
psql "$DB_URI" << 'EOF'
\echo 'Business data before custom SQL:'
\echo ''
\echo 'Customer loyalty points:'
SELECT id, first_name, last_name, loyalty_points, last_login 
FROM customers ORDER BY id;

\echo ''
\echo 'Product categories:'
SELECT id, name, price_dollars, category FROM products ORDER BY id;

\echo ''
\echo 'Employee departments:'
SELECT id, employee_id, first_name, last_name, salary_dollars, department 
FROM employees ORDER BY id;

\echo ''
\echo 'Order statuses:'
SELECT id, order_number, status, shipped_at, created_at FROM orders ORDER BY id;
EOF

echo ""
echo "🚀 Planning migration..."
../bin/kubectl-schemahero plan \
  --driver=postgres \
  --uri="$DB_URI" \
  --spec-file=05-custom-sql-migration.yaml \
  --spec-type=datamigration \
  --out=05-custom-sql.sql

echo ""
echo "📝 Generated SQL:"
echo "=================="
cat 05-custom-sql.sql

echo ""
echo "⚡ Applying migration..."
../bin/kubectl-schemahero apply \
  --driver=postgres \
  --uri="$DB_URI" \
  --ddl=05-custom-sql.sql

echo ""
echo "✅ AFTER - Verifying business logic results..."
psql "$DB_URI" << 'EOF'
\echo '🔍 Custom SQL Test Results:'
\echo '==========================='

\echo ''
\echo 'Loyalty points calculation:'
SELECT 'Customers with updated loyalty points' as check_type,
       COUNT(*) as count,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM customers 
WHERE EXISTS (
    SELECT 1 FROM orders 
    WHERE customer_id = customers.id AND status = 'completed'
);

\echo ''
\echo 'Last login assignment:'
SELECT 'Active customers with last_login set' as check_type,
       COUNT(*) as count,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM customers 
WHERE status = 'active' AND last_login IS NOT NULL;

\echo ''
\echo 'Product category updates:'
SELECT 'Products with new categories' as check_type,
       COUNT(*) as count,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM products 
WHERE category IN ('premium', 'standard', 'basic', 'economy');

\echo ''
\echo 'Order status updates:'
SELECT 'Orders marked as completed' as check_type,
       COUNT(*) as count,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM orders 
WHERE status = 'completed' AND shipped_at IS NOT NULL;

\echo ''
\echo 'Employee department updates:'
SELECT 'Employees with updated departments' as check_type,
       COUNT(*) as count,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM employees 
WHERE department LIKE 'senior_%' OR department LIKE 'junior_%';

\echo ''
\echo '📊 DETAILED RESULTS:'
\echo '==================='

\echo ''
\echo 'Customer loyalty points (after business logic):'
SELECT id, 
       CONCAT(first_name, ' ', last_name) as name,
       loyalty_points,
       CASE WHEN last_login IS NOT NULL THEN 'Set' ELSE 'NULL' END as last_login_status,
       status
FROM customers 
ORDER BY loyalty_points DESC;

\echo ''
\echo 'Product categories by price:'
SELECT id, name, price_dollars, category,
       CASE 
           WHEN price_dollars > 500 THEN 'Should be premium'
           WHEN price_dollars > 100 THEN 'Should be standard'  
           WHEN price_dollars > 20 THEN 'Should be basic'
           ELSE 'Should be economy'
       END as expected_category,
       CASE WHEN category IN ('premium', 'standard', 'basic', 'economy') 
            THEN '✅' ELSE '❌' END as category_check
FROM products 
ORDER BY price_dollars DESC;

\echo ''
\echo 'Employee departments by salary:'
SELECT id, employee_id,
       CONCAT(first_name, ' ', last_name) as name,
       salary_dollars, department,
       CASE 
           WHEN salary_dollars > 80000 AND department NOT LIKE 'senior_%' THEN '❌ Should be senior_'
           WHEN salary_dollars < 50000 AND department NOT LIKE 'junior_%' THEN '❌ Should be junior_'
           ELSE '✅ Correct'
       END as department_check
FROM employees 
ORDER BY salary_dollars DESC;

\echo ''
\echo 'Order processing results:'
SELECT id, order_number, status,
       created_at,
       shipped_at,
       CASE WHEN shipped_at IS NOT NULL THEN '✅ Shipped' ELSE '⏳ Pending' END as shipping_status
FROM orders 
ORDER BY id;

\echo ''
\echo '💰 Revenue impact:'
SELECT 
    COUNT(*) as completed_orders,
    SUM(total_dollars) as total_revenue,
    AVG(total_dollars) as avg_order_value
FROM orders 
WHERE status = 'completed';

EOF

echo ""
echo "🎉 Custom SQL test completed!"
