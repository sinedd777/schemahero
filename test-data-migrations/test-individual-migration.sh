#!/bin/bash

# Test individual migration file
set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <migration-file.yaml>"
    echo ""
    echo "Available migration files:"
    ls -1 *-migration.yaml 2>/dev/null || echo "  No migration files found"
    exit 1
fi

MIGRATION_FILE="$1"
DB_URI="postgres://testuser:testpass@localhost:5432/schemahero_test"
export PGPASSWORD="testpass"

if [ ! -f "$MIGRATION_FILE" ]; then
    echo "❌ Migration file not found: $MIGRATION_FILE"
    exit 1
fi

BASE_NAME=$(basename "$MIGRATION_FILE" .yaml)
OUTPUT_FILE="${BASE_NAME}.sql"

echo "🧪 Testing individual migration: $MIGRATION_FILE"
echo "=============================================="

echo ""
echo "🚀 Planning migration..."
../bin/kubectl-schemahero plan \
  --driver=postgres \
  --uri="$DB_URI" \
  --spec-file="$MIGRATION_FILE" \
  --spec-type=datamigration \
  --out="$OUTPUT_FILE"

echo ""
echo "📝 Generated SQL ($OUTPUT_FILE):"
echo "============================="
cat "$OUTPUT_FILE"

echo ""
echo "⚡ Applying migration..."
../bin/kubectl-schemahero apply \
  --driver=postgres \
  --uri="$DB_URI" \
  --ddl="$OUTPUT_FILE"

echo ""
echo "✅ Migration applied successfully!"
echo "📁 SQL saved to: $OUTPUT_FILE"
