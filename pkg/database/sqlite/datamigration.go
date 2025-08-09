// Data migration placeholder implementation for SQLite
package sqlite

import schemasv1alpha4 "github.com/schemahero/schemahero/pkg/apis/schemas/v1alpha4"

func PlanSqliteDataMigration(uri string, migrationName string, operations []schemasv1alpha4.DataMigrationOperation) ([]string, error) {
	return []string{}, nil // TODO: implement
}
