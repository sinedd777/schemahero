-- Data Migration: static-updates-test (Operation 1);
UPDATE "customers" SET "status" = 'active', "region" = 'us-east-1', "notification_enabled" = 'true' WHERE status IS NULL;
-- Data Migration: static-updates-test (Operation 2);
UPDATE "products" SET "status" = 'active' WHERE status IS NULL;
-- Data Migration: static-updates-test (Operation 3);
UPDATE "employees" SET "status" = 'active', "timezone" = 'UTC' WHERE status IS NULL OR timezone IS NULL;
-- Data Migration: static-updates-test (Operation 4);
UPDATE "orders" SET "status" = 'pending', "updated_at" = CURRENT_TIMESTAMP WHERE status IS NULL;
