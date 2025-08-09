#!/bin/bash

# Setup PostgreSQL user for SchemaHero testing
set -e

echo "🔧 Setting up PostgreSQL user for SchemaHero testing..."

# Check if we can connect to PostgreSQL as superuser
if ! psql -U postgres -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ Cannot connect to PostgreSQL as 'postgres' user"
    echo ""
    echo "💡 Try one of these options:"
    echo "   1. Connect as your system user: psql -U $(whoami)"
    echo "   2. Connect as postgres: sudo -u postgres psql"
    echo "   3. Use your existing PostgreSQL user"
    echo ""
    echo "🔧 To create the testuser manually, run:"
    echo "   psql -U <your-postgres-user> -c \"CREATE USER testuser WITH PASSWORD 'testpass' CREATEDB;\""
    exit 1
fi

echo "✅ Connected to PostgreSQL"

# Create testuser if it doesn't exist
echo "👤 Creating testuser..."
psql -U postgres << 'EOF'
-- Create user if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'testuser') THEN
        CREATE USER testuser WITH PASSWORD 'testpass' CREATEDB;
        RAISE NOTICE 'User testuser created';
    ELSE
        RAISE NOTICE 'User testuser already exists';
    END IF;
END
$$;

-- Grant necessary permissions
GRANT CREATEDB TO testuser;
EOF

echo "✅ PostgreSQL user setup complete!"
echo ""
echo "📋 User details:"
echo "   Username: testuser"
echo "   Password: testpass"
echo "   Permissions: CREATEDB"
echo ""
echo "🚀 Now you can run: ./setup-database.sh"
