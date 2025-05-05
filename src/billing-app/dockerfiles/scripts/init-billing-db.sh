#!/bin/bash

# Used when building Docker images. Sets up the database.

set -e

echo "===== Environment Variables ====="
env
echo "================================"

# Exit if required environment variables aren't set
[ -z "$DB_USER" ] && echo "DB_USER not set" && exit 1
[ -z "$DB_PASSWORD" ] && echo "DB_PASSWORD not set" && exit 1
[ -z "$DB_NAME" ] && echo "DB_NAME not set" && exit 1

# Connect to PostgreSQL and create the user and database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
    ALTER USER postgres WITH PASSWORD '$POSTGRES_PASSWORD';
    CREATE USER $DB_USER WITH SUPERUSER PASSWORD '$DB_PASSWORD';
    CREATE DATABASE $DB_NAME OWNER $DB_USER;
    GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
EOSQL

# Configure PostgreSQL to allow remote connections
echo "listen_addresses = '*'" >> /var/lib/postgresql/data/postgresql.conf
echo "host all all all md5" >> /var/lib/postgresql/data/pg_hba.conf