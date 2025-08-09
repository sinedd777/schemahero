# Data Migrations Testing Suite

This directory contains comprehensive tests for SchemaHero data migrations functionality.

## Prerequisites

1. PostgreSQL running locally (or update connection strings)
2. SchemaHero CLI built: `go build -o bin/kubectl-schemahero ./cmd/kubectl-schemahero`

## Quick Start

```bash
# 1. Set up test database
./setup-database.sh

# 2. Run all tests
./run-all-tests.sh

# 3. Clean up
./cleanup.sh
```

## Test Structure

- `setup-database.sh` - Creates test database and initial schema
- `01-setup-data.sql` - Populates initial test data
- `02-*-migration.yaml` - Data migration definitions
- `verify-*.sql` - Scripts to check results
- `run-test-*.sh` - Individual test runners
- `run-all-tests.sh` - Runs complete test suite

## Database Connection

Default connection: `postgres://testuser:testpass@localhost:5432/schemahero_test`

Update scripts if your setup differs.
