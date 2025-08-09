#!/bin/bash

# SchemaHero Data Migration Test Setup - Custom User Version
set -e

# Configuration - UPDATE THESE VALUES
DB_NAME="schemahero_test"
DB_USER="${DB_USER:-$(whoami)}"  # Use your system username by default
DB_PASS="${DB_PASS:-}"           # Leave empty if no password needed
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"

echo "🚀 Setting up test database for SchemaHero data migrations..."
echo "📋 Using connection details:"
echo "   Host: $DB_HOST:$DB_PORT"
echo "   User: $DB_USER"
echo "   Database: $DB_NAME"

# Set password if provided
if [ -n "$DB_PASS" ]; then
    export PGPASSWORD="$DB_PASS"
fi

# Build connection string
if [ -n "$DB_PASS" ]; then
    DB_URI="postgres://$DB_USER:$DB_PASS@$DB_HOST:$DB_PORT/$DB_NAME"
else
    DB_URI="postgres://$DB_USER@$DB_HOST:$DB_PORT/$DB_NAME"
fi

# Test connection first
echo "🔍 Testing PostgreSQL connection..."
if ! psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ Cannot connect to PostgreSQL!"
    echo ""
    echo "💡 Common solutions:"
    echo "   1. Check if PostgreSQL is running: brew services start postgresql"
    echo "   2. Try a different user: DB_USER=postgres ./setup-database-custom.sh"
    echo "   3. Set password if needed: DB_PASS=yourpass ./setup-database-custom.sh"
    echo "   4. Check connection: psql -U $DB_USER -c 'SELECT 1;'"
    exit 1
fi

echo "✅ PostgreSQL connection OK"

# Create database if it doesn't exist
echo "📦 Creating database $DB_NAME..."
createdb -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" 2>/dev/null || echo "Database already exists"

# Create initial schema
echo "🏗️  Creating initial schema..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" << 'EOF'
-- Drop existing tables if they exist
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;

-- Create customers table
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP,
    status VARCHAR(20),
    region VARCHAR(50),
    loyalty_points INTEGER DEFAULT 0,
    full_name VARCHAR(101),  -- Will be calculated
    display_email VARCHAR(100), -- Will be calculated
    timezone VARCHAR(50),
    notification_enabled BOOLEAN,
    last_login TIMESTAMP
);

-- Create products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    price_cents INTEGER,
    price_dollars DECIMAL(10,2), -- Will be calculated
    category VARCHAR(50),
    sku VARCHAR(50),
    status VARCHAR(20),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create employees table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    employee_id VARCHAR(20),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    department VARCHAR(50),
    hire_date TIMESTAMP,
    salary_cents INTEGER,
    salary_dollars DECIMAL(10,2), -- Will be calculated
    status VARCHAR(20),
    timezone VARCHAR(50),
    full_name VARCHAR(101) -- Will be calculated
);

-- Create orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50),
    customer_id INTEGER REFERENCES customers(id),
    total_cents INTEGER,
    total_dollars DECIMAL(10,2), -- Will be calculated
    tax_cents INTEGER,
    tax_dollars DECIMAL(10,2), -- Will be calculated
    status VARCHAR(20),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    shipped_at TIMESTAMP
);

-- Create order_items table
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER,
    unit_price_cents INTEGER,
    unit_price_dollars DECIMAL(10,2), -- Will be calculated
    total_cents INTEGER,
    total_dollars DECIMAL(10,2) -- Will be calculated
);

COMMIT;
EOF

echo "✅ Database setup complete!"
echo ""
echo "📊 Connection details for tests:"
echo "   URI: $DB_URI"
echo ""
echo "💡 Update other scripts to use your connection:"
echo "   export DB_USER=$DB_USER"
if [ -n "$DB_PASS" ]; then
    echo "   export DB_PASS=$DB_PASS"
fi
echo "   export DB_URI=\"$DB_URI\""
echo ""
echo "🚀 Now run: ./run-all-tests-custom.sh"
