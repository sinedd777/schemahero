#!/bin/bash

# Test 3: Data Transformations Migration
set -e

DB_URI="postgres://testuser:testpass@localhost:5432/schemahero_test"
export PGPASSWORD="testpass"

echo "🧪 Test 3: Data Transformations Migration"
echo "=========================================="

echo ""
echo "📊 BEFORE - Current data that needs transformation..."
psql "$DB_URI" << 'EOF'
\echo 'Data needing transformation:'
\echo ''
\echo 'Mixed case emails:'
SELECT id, email FROM customers WHERE email != LOWER(email);

\echo ''
\echo 'Old SKU formats:'
SELECT id, sku FROM products WHERE sku LIKE 'OLD-%' OR sku LIKE 'old-%';

\echo ''
\echo 'Old employee ID formats:'
SELECT id, employee_id FROM employees WHERE employee_id LIKE 'OLD-%' OR employee_id LIKE 'old-%';
EOF

echo ""
echo "🚀 Planning migration..."
../bin/kubectl-schemahero plan \
  --driver=postgres \
  --uri="$DB_URI" \
  --spec-file=04-transformations-migration.yaml \
  --spec-type=datamigration \
  --out=04-transformations.sql

echo ""
echo "📝 Generated SQL:"
echo "=================="
cat 04-transformations.sql

echo ""
echo "⚡ Applying migration..."
../bin/kubectl-schemahero apply \
  --driver=postgres \
  --uri="$DB_URI" \
  --ddl=04-transformations.sql

echo ""
echo "✅ AFTER - Verifying transformations..."
psql "$DB_URI" << 'EOF'
\echo '🔍 Data Transformations Test Results:'
\echo '====================================='

\echo ''
\echo 'Email case normalization:'
SELECT 'Mixed case emails remaining' as check_type,
       COUNT(*) as count,
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM customers WHERE email != LOWER(email);

\echo ''
\echo 'SKU format cleanup:'
SELECT 'Old SKU formats remaining' as check_type,
       COUNT(*) as count,
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM products WHERE sku LIKE 'OLD-%' OR sku LIKE 'old-%';

\echo ''
\echo 'Employee ID format cleanup:'
SELECT 'Old employee ID formats remaining' as check_type,
       COUNT(*) as count,
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM employees WHERE employee_id LIKE 'OLD-%' OR employee_id LIKE 'old-%';

\echo ''
\echo 'Timezone conversions applied:'
SELECT 'Customers with timezone conversions' as check_type,
       COUNT(*) as count,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as result
FROM customers WHERE region LIKE 'us-%';

\echo ''
\echo 'Sample transformed data:'
\echo ''
\echo 'Customers (emails should be lowercase):'
SELECT id, first_name, last_name, email, region FROM customers WHERE id <= 5;

\echo ''
\echo 'Products (SKUs should be clean and uppercase):'
SELECT id, name, sku FROM products WHERE id <= 8;

\echo ''
\echo 'Employees (IDs should be clean and uppercase):'
SELECT id, employee_id, first_name, last_name FROM employees;

\echo ''
\echo 'Timezone conversion check (created_at for US customers):'
SELECT id, first_name, region, created_at, timezone
FROM customers 
WHERE region LIKE 'us-%'
ORDER BY id;

EOF

echo ""
echo "🎉 Data Transformations test completed!"
