docker start labtrack-mysql
docker exec -it labtrack-mysql mysql -uroot -p
docker exec -i labtrack-mysql mysql -uroot -p"$MYSQL_PASSWORD" < portfolio-1-database-design/seed-data.sql
docker exec -i labtrack-mysql mysql -uroot -p"$MYSQL_PASSWORD" < portfolio-2-query-optimisation/expand-seed-data.sql