#!/bin/bash

# Used when building Docker images. Sets up the database.
set -e

echo "===== Environment Variables ====="
env
echo "================================"

# Exit if required environment variables aren't set
[ -z "$BILLING_DB_USER" ] && echo "BILLING_DB_USER not set" && exit 1
[ -z "$BILLING_DB_PASSWORD" ] && echo "BILLING_DB_PASSWORD not set" && exit 1
[ -z "$BILLING_DB_NAME" ] && echo "BILLING_DB_NAME not set" && exit 1
[ -z "$POSTGRES_USER" ] && echo "POSTGRES_USER not set" && exit 1
[ -z "$BILLING_POSTGRES_PASSWORD" ] && echo "BILLING_POSTGRES_PASSWORD not set" && exit 1

# Connect to PostgreSQL and create the user and database if they don't exist
psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
    -- Update superuser password if it exists
    DO \$\$
    BEGIN
        -- Update the superuser password safely (works with any superuser name)
        ALTER USER current_user WITH PASSWORD '$BILLING_POSTGRES_PASSWORD';
        
        -- Create application user if doesn't exist, otherwise update password
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$BILLING_DB_USER') THEN
            CREATE USER $BILLING_DB_USER WITH PASSWORD '$BILLING_DB_PASSWORD';
        ELSE
            ALTER USER $BILLING_DB_USER WITH PASSWORD '$BILLING_DB_PASSWORD';
        END IF;
    END
    \$\$;
    
    -- Create the database if it doesn't exist
    SELECT 'CREATE DATABASE $BILLING_DB_NAME OWNER $BILLING_DB_USER'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$BILLING_DB_NAME');
    
    -- Grant privileges (safe to run multiple times)
    GRANT ALL PRIVILEGES ON DATABASE $BILLING_DB_NAME TO $BILLING_DB_USER;
EOSQL

# Configure PostgreSQL to allow remote connections (only if not already configured)
if ! grep -q "listen_addresses = '\*'" /var/lib/postgresql/data/postgresql.conf; then
    echo "listen_addresses = '*'" >> /var/lib/postgresql/data/postgresql.conf
fi

if ! grep -q "host all all all md5" /var/lib/postgresql/data/pg_hba.conf; then
    echo "host all all all md5" >> /var/lib/postgresql/data/pg_hba.conf
fi