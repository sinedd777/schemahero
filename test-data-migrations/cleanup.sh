#!/bin/bash

# Cleanup script for SchemaHero data migration tests
set -e

DB_NAME="schemahero_test"
DB_USER="testuser"
DB_PASS="testpass"
DB_HOST="localhost"
DB_PORT="5432"

export PGPASSWORD="$DB_PASS"

echo "🧹 Cleaning up SchemaHero data migration tests..."

# Drop test database
echo "🗑️  Dropping test database..."
dropdb -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" 2>/dev/null || echo "Database doesn't exist or already dropped"

# Remove generated SQL files
echo "🗑️  Removing generated SQL files..."
rm -f 02-static-updates.sql
rm -f 03-calculated-updates.sql  
rm -f 04-transformations.sql
rm -f 05-custom-sql.sql

echo "✅ Cleanup completed!"
echo ""
echo "💡 To run tests again:"
echo "   1. ./setup-database.sh"
echo "   2. ./run-all-tests.sh"
