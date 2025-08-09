# Data Migrations in SchemaHero

SchemaHero now supports data migrations in addition to schema migrations. This feature allows you to perform data transformations and updates as part of your migration workflow.

## Overview

Data migrations in SchemaHero support:
- **Static Updates**: Update columns with static values
- **Calculated Updates**: Update columns using calculated expressions from other columns
- **Data Transformations**: Perform data transformations (timezone conversions, type casts, etc.)
- **Custom SQL**: Execute arbitrary SQL for complex migrations

## Usage

### 1. Using the CLI

You can plan and apply data migrations using the SchemaHero CLI:

```bash
# Plan data migrations
kubectl-schemahero plan \
  --driver=postgres \
  --uri="postgres://user:password@localhost:5432/db" \
  --spec-file=data-migration.yaml \
  --spec-type=datamigration

# Apply the generated SQL
kubectl-schemahero apply \
  --driver=postgres \
  --uri="postgres://user:password@localhost:5432/db" \
  --ddl=migration.sql
```

### 2. Kubernetes Resources

Data migrations can be defined as Kubernetes resources using the `DataMigration` CRD:

```yaml
apiVersion: schemas.schemahero.io/v1alpha4
kind: DataMigration
metadata:
  name: user-data-migration
  namespace: default
spec:
  database: mydb
  name: user-data-migration
  executionOrder: after_schema  # Run after schema changes
  idempotent: true              # Can be run multiple times safely
  schema:
    postgres:
      - staticUpdate:
          table: users
          set:
            status: "active"
            updated_at: "CURRENT_TIMESTAMP"
          where: "status IS NULL"
```

## Migration Types

### Static Updates

Update columns with static values:

```yaml
- staticUpdate:
    table: users
    set:
      status: "active"
      region: "us-east-1"
    where: "status IS NULL"
```

### Calculated Updates

Update columns using calculated expressions:

```yaml
- calculatedUpdate:
    table: users
    calculations:
      - column: full_name
        expression: "CONCAT(first_name, ' ', last_name)"
      - column: display_email
        expression: "LOWER(email)"
    where: "full_name IS NULL"
```

### Data Transformations

Perform common data transformations:

#### Timezone Conversion
```yaml
- transformUpdate:
    table: events
    transformations:
      - column: created_at
        transformType: timezone_convert
        fromValue: UTC
        toValue: America/New_York
    where: "created_at IS NOT NULL"
```

#### Type Casting
```yaml
- transformUpdate:
    table: products
    transformations:
      - column: price
        transformType: type_cast
        toValue: "decimal(10,2)"
```

#### Format Changes
```yaml
- transformUpdate:
    table: users
    transformations:
      - column: username
        transformType: format_change
        toValue: lowercase
```

#### String Transformations
```yaml
- transformUpdate:
    table: products
    transformations:
      - column: sku
        transformType: string_transform
        parameters:
          type: replace
          old: "OLD-"
          new: "NEW-"
```

### Custom SQL

Execute arbitrary SQL for complex migrations:

```yaml
- customSQL:
    sql: |
      UPDATE orders 
      SET total_with_tax = subtotal * 1.08,
          status = 'processed'
      WHERE status = 'pending' 
        AND created_at > CURRENT_DATE - INTERVAL '30 days'
    validate: true  # Perform basic SQL validation
```

## Configuration Options

### Execution Order

Control when data migrations run relative to schema changes:

- `before_schema`: Run before schema migrations
- `after_schema`: Run after schema migrations (default)

### Idempotency

Mark migrations as idempotent if they can be run multiple times safely:

```yaml
spec:
  idempotent: true  # Can be re-run without issues
```

### Dependencies

Specify dependencies on other migrations:

```yaml
spec:
  requires:
    - table-schema-migration
    - user-table-migration
```

## Database Support

Data migrations are currently supported for:

- ✅ **PostgreSQL** - Full implementation
- 🚧 **MySQL** - Placeholder (needs implementation)
- 🚧 **SQLite** - Placeholder (needs implementation)
- 🚧 **TimescaleDB** - Placeholder (needs implementation)
- 🚧 **CockroachDB** - Uses PostgreSQL implementation
- 🚧 **Cassandra** - Placeholder (needs implementation)
- 🚧 **RQLite** - Placeholder (needs implementation)

## Examples

### Simple Data Migration (CLI Format)

```yaml
# simple-data-migration.yaml
database: mydb
name: set-default-values
executionOrder: after_schema
idempotent: true
schema:
  postgres:
    - staticUpdate:
        table: users
        set:
          status: "active"
          region: "unknown"
        where: "status IS NULL"
```

### Complex Kubernetes Resource

```yaml
# user-data-migration.yaml
apiVersion: schemas.schemahero.io/v1alpha4
kind: DataMigration
metadata:
  name: user-data-migration
  namespace: production
spec:
  database: userdb
  name: user-data-migration
  executionOrder: after_schema
  idempotent: false
  requires:
    - user-table-schema
  schema:
    postgres:
      # Set default values for new columns
      - staticUpdate:
          table: users
          set:
            notification_enabled: "true"
            last_login: "CURRENT_TIMESTAMP"
          where: "notification_enabled IS NULL"
      
      # Calculate derived fields
      - calculatedUpdate:
          table: users
          calculations:
            - column: display_name
              expression: "COALESCE(full_name, CONCAT(first_name, ' ', last_name), email)"
          where: "display_name IS NULL"
      
      # Transform existing data
      - transformUpdate:
          table: users
          transformations:
            - column: email
              transformType: format_change
              toValue: lowercase
            - column: timezone
              transformType: timezone_convert
              fromValue: UTC
              toValue: America/New_York
          where: "email != LOWER(email) OR timezone_converted = false"
      
      # Complex business logic
      - customSQL:
          sql: |
            UPDATE users 
            SET subscription_tier = CASE 
              WHEN total_purchases > 1000 THEN 'premium'
              WHEN total_purchases > 100 THEN 'standard'
              ELSE 'basic'
            END,
            loyalty_points = FLOOR(total_purchases * 0.1)
            WHERE subscription_tier IS NULL
          validate: true
```

## Best Practices

1. **Test First**: Always test data migrations on a copy of your production data
2. **Use Transactions**: Wrap complex migrations in transactions when possible
3. **Idempotent Operations**: Design migrations to be idempotent when feasible
4. **Backup Data**: Always backup your data before running migrations
5. **Validate Results**: Add validation queries to verify migration success
6. **Incremental Approach**: Break complex migrations into smaller, manageable steps

## Error Handling

Data migrations include built-in validation and error handling:

- **SQL Validation**: Basic validation for custom SQL to prevent dangerous operations
- **Type Safety**: Validation of migration operation structure
- **Dependency Checking**: Ensures required migrations have run first
- **Status Tracking**: Migration execution status is tracked and reported

## Monitoring

Monitor your data migrations through:

- **Execution Status**: Check the `status.executionStatus` field
- **Error Messages**: Review `status.errorMessage` for failure details
- **Timestamps**: Track execution times via `status.executionTimestamp`
- **SHA Tracking**: Detect changes via `status.lastExecutedMigrationSpecSHA`

## Future Enhancements

Planned improvements include:

- **Rollback Support**: Ability to rollback data migrations
- **Progress Tracking**: Progress reporting for long-running migrations
- **Parallel Execution**: Support for parallel migration execution
- **Advanced Validation**: More sophisticated SQL validation
- **Integration Testing**: Built-in testing framework for migrations
