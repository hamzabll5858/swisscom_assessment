
CREATE DATABASE moviesdb
WITH
OWNER = postgres
ENCODING = 'UTF8'
LC_COLLATE = 'en_US.utf8'
LC_CTYPE = 'en_US.utf8'
TABLESPACE = pg_default
CONNECTION LIMIT = -1
IS_TEMPLATE = False;


migrate -path database/migration -database "postgresql://postgres:postgres@localhost:5432/moviesdb?sslmode=disable" -verbose up


DROP DATABASE IF EXISTS moviesdb;




curl --location --request POST 'http://localhost:8008/movies/' \
--header 'Content-Type: application/json' \
--data-raw '{
"id":1,
"name":"meat",
"type":"non-vegan"
}'

curl --location --request GET 'http://localhost:8080/movies/' \
--header 'Content-Type: application/json'
