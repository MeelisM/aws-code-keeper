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
[ -z "$POSTGRES_USER" ] && echo "POSTGRES_USER not set" && exit 1
[ -z "$POSTGRES_PASSWORD" ] && echo "POSTGRES_PASSWORD not set" && exit 1

# Connect to PostgreSQL and create the user and database if they don't exist
psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
    -- Create the application user if it doesn't exist
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$DB_USER') THEN
            CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
        ELSE
            ALTER USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
        END IF;
    END
    \$\$;
    
    -- Create the database if it doesn't exist - fixed to actually execute the CREATE command
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME') THEN
            CREATE DATABASE $DB_NAME;
        END IF;
    END
    \$\$;
    
    -- Grant necessary privileges to the application user
    GRANT CONNECT ON DATABASE $DB_NAME TO $DB_USER;
EOSQL

# Connect to the newly created database to set up permissions
psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" --dbname "$DB_NAME" <<-EOSQL
    -- Grant schema privileges
    GRANT USAGE ON SCHEMA public TO $DB_USER;
    GRANT CREATE ON SCHEMA public TO $DB_USER;
    
    -- Grant table privileges (for future tables)
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO $DB_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO $DB_USER;
EOSQL

# Configure PostgreSQL to allow remote connections (only if they don't already exist)
if ! grep -q "listen_addresses = '\*'" /var/lib/postgresql/data/postgresql.conf; then
    echo "listen_addresses = '*'" >> /var/lib/postgresql/data/postgresql.conf
fi

if ! grep -q "host all all all md5" /var/lib/postgresql/data/pg_hba.conf; then
    echo "host all all all md5" >> /var/lib/postgresql/data/pg_hba.conf
fi