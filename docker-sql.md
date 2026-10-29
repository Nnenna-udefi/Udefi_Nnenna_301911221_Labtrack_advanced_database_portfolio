docker start labtrack-mysql
docker exec -it labtrack-mysql mysql -uroot -p
docker exec -i labtrack-mysql mysql -uroot -p"$MYSQL_PASSWORD" < portfolio-1-database-design/seed-data.sql
docker exec -i labtrack-mysql mysql -uroot -p"$MYSQL_PASSWORD" < portfolio-2-query-optimisation/expand-seed-data.sql

Portfolio 3 is about making sure the database stays correct when multiple people are working with it at the same time.

COMMIT means: “Keep my changes.”
ROLLBACK means: “Undo my unsaved changes.”
Isolation rules determine what each worker can see while the changes are happening.
CONCURRENCY — Handle simultaneous work safely


START TRANSACTION begins the transaction.
UPDATE changes the order status.
SELECT lets you inspect the change before finishing.
COMMIT saves the change.