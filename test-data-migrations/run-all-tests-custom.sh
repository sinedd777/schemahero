#!/bin/bash

# Complete SchemaHero Data Migrations Test Suite - Custom User Version
set -e

# Configuration - will use environment variables or defaults
DB_USER="${DB_USER:-$(whoami)}"
DB_PASS="${DB_PASS:-}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-schemahero_test}"

# Build connection string
if [ -n "$DB_PASS" ]; then
    DB_URI="postgres://$DB_USER:$DB_PASS@$DB_HOST:$DB_PORT/$DB_NAME"
    export PGPASSWORD="$DB_PASS"
else
    DB_URI="postgres://$DB_USER@$DB_HOST:$DB_PORT/$DB_NAME"
fi

echo "🚀 SchemaHero Data Migrations - Complete Test Suite (Custom User)"
echo "================================================================"
echo "📋 Using connection:"
echo "   User: $DB_USER"
echo "   Database: $DB_NAME"
echo "   URI: $DB_URI"

# Check if binary exists
if [ ! -f "../bin/kubectl-schemahero" ]; then
    echo "❌ kubectl-schemahero binary not found!"
    echo "   Please run: go build -o bin/kubectl-schemahero ./cmd/kubectl-schemahero"
    echo "   from the project root directory"
    exit 1
fi

# Check database connection
echo ""
echo "🔍 Checking database connection..."
if ! psql "$DB_URI" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ Cannot connect to database!"
    echo "   URI: $DB_URI"
    echo ""
    echo "💡 Try:"
    echo "   1. Check if PostgreSQL is running"
    echo "   2. Run: ./setup-database-custom.sh"
    echo "   3. Set correct credentials:"
    echo "      export DB_USER=your_user"
    echo "      export DB_PASS=your_password"
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

# Function to run migration test
run_migration_test() {
    local test_name="$1"
    local migration_file="$2"
    local output_file="$3"
    
    echo ""
    echo "▶️  Running $test_name..."
    
    # Plan migration
    ../bin/kubectl-schemahero plan \
        --driver=postgres \
        --uri="$DB_URI" \
        --spec-file="$migration_file" \
        --spec-type=datamigration \
        --out="$output_file"
    
    echo "📝 Generated SQL:"
    cat "$output_file"
    
    # Apply migration
    echo ""
    echo "⚡ Applying migration..."
    ../bin/kubectl-schemahero apply \
        --driver=postgres \
        --uri="$DB_URI" \
        --ddl="$output_file"
    
    echo "✅ $test_name completed!"
}

# Run all tests
run_migration_test "Test 1: Static Updates" "02-static-updates-migration.yaml" "02-static-updates.sql"
run_migration_test "Test 2: Calculated Updates" "03-calculated-updates-migration.yaml" "03-calculated-updates.sql"
run_migration_test "Test 3: Data Transformations" "04-transformations-migration.yaml" "04-transformations.sql"
run_migration_test "Test 4: Custom SQL" "05-custom-sql-migration.yaml" "05-custom-sql.sql"

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
echo "   - Connect to the database: psql \"$DB_URI\""
echo "   - Run individual tests again"
echo "   - Clean up with: ./cleanup-custom.sh"
