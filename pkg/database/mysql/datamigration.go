// Data migration placeholder implementation for MySQL
package mysql

import schemasv1alpha4 "github.com/schemahero/schemahero/pkg/apis/schemas/v1alpha4"

func PlanMysqlDataMigration(uri string, migrationName string, operations []schemasv1alpha4.DataMigrationOperation) ([]string, error) {
	return []string{}, nil // TODO: implement
}
