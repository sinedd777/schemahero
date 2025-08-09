#!/bin/bash

# Test 1: Static Updates Migration
set -e

DB_URI="postgres://testuser:testpass@localhost:5432/schemahero_test"
export PGPASSWORD="testpass"

echo "🧪 Test 1: Static Updates Migration"
echo "===================================="

echo ""
echo "📊 BEFORE - Checking current state..."
psql "$DB_URI" -f verify-before.sql

echo ""
echo "🚀 Planning migration..."
../bin/kubectl-schemahero plan \
  --driver=postgres \
  --uri="$DB_URI" \
  --spec-file=02-static-updates-migration.yaml \
  --spec-type=datamigration \
  --out=02-static-updates.sql

echo ""
echo "📝 Generated SQL:"
echo "=================="
cat 02-static-updates.sql

echo ""
echo "⚡ Applying migration..."
../bin/kubectl-schemahero apply \
  --driver=postgres \
  --uri="$DB_URI" \
  --ddl=02-static-updates.sql

echo ""
echo "✅ AFTER - Verifying results..."
psql "$DB_URI" << 'EOF'
\echo '🔍 Static Updates Test Results:'
\echo '==============================='

\echo ''
\echo 'Customers - NULL status check:'
SELECT 'customers.status' as field, 
       COUNT(*) as null_count,
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM customers WHERE status IS NULL;

\echo ''
\echo 'Products - NULL status check:'
SELECT 'products.status' as field,
       COUNT(*) as null_count, 
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM products WHERE status IS NULL;

\echo ''
\echo 'Employees - NULL status/timezone check:'
SELECT 'employees.status' as field,
       COUNT(*) as null_count,
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM employees WHERE status IS NULL
UNION ALL
SELECT 'employees.timezone',
       COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM employees WHERE timezone IS NULL;

\echo ''
\echo 'Orders - NULL status check:'
SELECT 'orders.status' as field,
       COUNT(*) as null_count,
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM orders WHERE status IS NULL;

\echo ''
\echo 'Sample updated records:'
SELECT 'Customer' as type, id, 
       CONCAT(first_name, ' ', last_name) as name,
       status, region
FROM customers WHERE id <= 3
UNION ALL
SELECT 'Product', id, name, status, '' as region
FROM products WHERE id <= 3
ORDER BY type, id;

EOF

echo ""
echo "🎉 Static Updates test completed!"
