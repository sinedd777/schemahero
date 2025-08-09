#!/bin/bash

# Complete SchemaHero Data Migrations Test Suite
set -e

echo "🚀 SchemaHero Data Migrations - Complete Test Suite"
echo "==================================================="

# Check if binary exists
if [ ! -f "../bin/kubectl-schemahero" ]; then
    echo "❌ kubectl-schemahero binary not found!"
    echo "   Please run: go build -o bin/kubectl-schemahero ./cmd/kubectl-schemahero"
    echo "   from the project root directory"
    exit 1
fi

# Check database connection
DB_URI="postgres://testuser:testpass@localhost:5432/schemahero_test"
export PGPASSWORD="testpass"

echo ""
echo "🔍 Checking database connection..."
if ! psql "$DB_URI" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ Cannot connect to database!"
    echo "   Please ensure PostgreSQL is running and database is set up"
    echo "   Run: ./setup-database.sh"
    exit 1
fi

echo "✅ Database connection OK"

# Load initial test data
echo ""
echo "🌱 Loading initial test data..."
psql "$DB_URI" -f 01-setup-data.sql

echo ""
echo "📊 INITIAL STATE - Before any migrations"
echo "========================================"
psql "$DB_URI" -f verify-before.sql

echo ""
echo ""
echo "🧪 RUNNING MIGRATION TESTS"
echo "=========================="

# Test 1: Static Updates
echo ""
echo "▶️  Running Test 1: Static Updates..."
chmod +x run-test-static.sh
./run-test-static.sh

# Test 2: Calculated Updates  
echo ""
echo "▶️  Running Test 2: Calculated Updates..."
chmod +x run-test-calculated.sh
./run-test-calculated.sh

# Test 3: Data Transformations
echo ""
echo "▶️  Running Test 3: Data Transformations..."
chmod +x run-test-transformations.sh
./run-test-transformations.sh

# Test 4: Custom SQL
echo ""
echo "▶️  Running Test 4: Custom SQL..."
chmod +x run-test-custom-sql.sh
./run-test-custom-sql.sh

echo ""
echo ""
echo "🎯 FINAL VERIFICATION"
echo "===================="
psql "$DB_URI" -f verify-after.sql

echo ""
echo ""
echo "📋 TEST SUMMARY"
echo "==============="

# Count test results
echo "🧪 Tests completed:"
echo "  ✅ Static Updates Migration"
echo "  ✅ Calculated Updates Migration" 
echo "  ✅ Data Transformations Migration"
echo "  ✅ Custom SQL Migration"

echo ""
echo "📁 Generated files:"
ls -la *.sql 2>/dev/null | grep -E "(02|03|04|05)-.*\.sql" || echo "  No SQL files found"

echo ""
echo "🔗 Database connection: $DB_URI"

echo ""
echo "🎉 ALL TESTS COMPLETED SUCCESSFULLY!"
echo ""
echo "💡 You can now:"
echo "   - Review the generated SQL files"
echo "   - Connect to the database to see final state"
echo "   - Run individual tests again"
echo "   - Clean up with: ./cleanup.sh"
