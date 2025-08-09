#!/bin/bash

# Test 2: Calculated Updates Migration
set -e

DB_URI="postgres://testuser:testpass@localhost:5432/schemahero_test"
export PGPASSWORD="testpass"

echo "🧪 Test 2: Calculated Updates Migration"
echo "========================================"

echo ""
echo "🚀 Planning migration..."
../bin/kubectl-schemahero plan \
  --driver=postgres \
  --uri="$DB_URI" \
  --spec-file=03-calculated-updates-migration.yaml \
  --spec-type=datamigration \
  --out=03-calculated-updates.sql

echo ""
echo "📝 Generated SQL:"
echo "=================="
cat 03-calculated-updates.sql

echo ""
echo "⚡ Applying migration..."
../bin/kubectl-schemahero apply \
  --driver=postgres \
  --uri="$DB_URI" \
  --ddl=03-calculated-updates.sql

echo ""
echo "✅ AFTER - Verifying results..."
psql "$DB_URI" << 'EOF'
\echo '🔍 Calculated Updates Test Results:'
\echo '==================================='

\echo ''
\echo 'Full name calculations:'
SELECT 'customers.full_name' as field,
       COUNT(*) as null_count,
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM customers WHERE full_name IS NULL OR full_name = ''
UNION ALL
SELECT 'employees.full_name',
       COUNT(*),
       CASE WHEN COUNT(*) <= 1 THEN '✅ PASS' ELSE '❌ FAIL' END  -- Allow 1 because Diana has NULL last_name
FROM employees WHERE full_name IS NULL OR full_name = '';

\echo ''
\echo 'Price conversions (cents to dollars):'
SELECT 'products.price_dollars' as field,
       COUNT(*) as null_count,
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM products WHERE price_dollars IS NULL AND price_cents IS NOT NULL
UNION ALL
SELECT 'employees.salary_dollars',
       COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM employees WHERE salary_dollars IS NULL AND salary_cents IS NOT NULL
UNION ALL
SELECT 'orders.total_dollars',
       COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM orders WHERE total_dollars IS NULL AND total_cents IS NOT NULL;

\echo ''
\echo 'Email normalization:'
SELECT 'customers.display_email' as field,
       COUNT(*) as null_count,
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM customers WHERE display_email IS NULL AND email IS NOT NULL;

\echo ''
\echo 'Sample calculated results:'
SELECT 'Customer' as type, id,
       first_name, last_name, full_name, 
       email, display_email
FROM customers WHERE id <= 5
ORDER BY id;

\echo ''
SELECT 'Product' as type, id, name,
       price_cents, price_dollars,
       CASE WHEN price_dollars = ROUND(price_cents::DECIMAL / 100, 2) 
            THEN '✅ Correct' 
            ELSE '❌ Wrong' END as calculation_check
FROM products WHERE id <= 5
ORDER BY id;

\echo ''
SELECT 'Employee' as type, id,
       first_name, last_name, full_name,
       salary_cents, salary_dollars,
       CASE WHEN salary_dollars = ROUND(salary_cents::DECIMAL / 100, 2) 
            THEN '✅ Correct' 
            ELSE '❌ Wrong' END as calculation_check
FROM employees WHERE id <= 5
ORDER BY id;

EOF

echo ""
echo "🎉 Calculated Updates test completed!"
