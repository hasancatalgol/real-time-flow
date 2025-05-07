#!/bin/bash
set -e
set -x

echo "Starting SQL Server..."
# Run SQL Server in the background using exec to maintain PID 1
exec /opt/mssql/bin/sqlservr &
pid=$!

echo "Waiting for SQL Server to start..."
until /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" &> /dev/null
do
    echo -n "."
    sleep 1
done
echo -e "\nSQL Server is up. Running initialization scripts..."

# Dataset handling
if [ -f /usr/src/app/initdb/dataset.csv ]; then
    echo "Copying dataset to SQL Server backup folder..."
    # No need for mkdir/chown if directory was pre-created in Dockerfile
    cp /usr/src/app/initdb/dataset.csv /var/opt/mssql/backup/dataset.csv
fi

# SQL initialization
if [ -f /usr/src/app/initdb/create_transactions.sql ]; then
    echo "Running create_transactions.sql..."
    /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -d master \
        -i /usr/src/app/initdb/create_transactions.sql
fi

echo "Initialization complete. SQL Server is now running."
wait $pid