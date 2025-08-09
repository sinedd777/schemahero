#!/bin/bash

# Cleanup script for SchemaHero data migration tests - Custom User Version
set -e

# Configuration
DB_USER="${DB_USER:-$(whoami)}"
DB_PASS="${DB_PASS:-}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-schemahero_test}"

# Set password if provided
if [ -n "$DB_PASS" ]; then
    export PGPASSWORD="$DB_PASS"
fi

echo "🧹 Cleaning up SchemaHero data migration tests..."
echo "📋 Using user: $DB_USER"

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
echo "   1. ./setup-database-custom.sh"
echo "   2. ./run-all-tests-custom.sh"
