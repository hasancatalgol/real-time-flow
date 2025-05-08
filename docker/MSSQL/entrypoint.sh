#!/bin/bash
set -e
set -x

# Start SQL Server in background
/opt/mssql/bin/sqlservr &

# Wait for SQL Server to be ready (max 30 attempts)
for i in {1..30}; do
  /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "${SA_PASSWORD}" -Q "SELECT 1" -N -C && break
  echo "Waiting for SQL Server to start..."
  sleep 2
done


# Final check
if ! /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "${SA_PASSWORD}" -Q "SELECT 1" -N -C; then
  echo "ERROR: SQL Server did not become ready in time."
  exit 1
fi

# Run all .sql scripts in /scripts (sorted)
SCRIPT_DIR="/var/opt/mssql/scripts"
for script in \
  "$SCRIPT_DIR/create_databases.sql" \
  "$SCRIPT_DIR/create_tables.sql" \
  "$SCRIPT_DIR/enable_cdc.sql"; do

  [ -f "$script" ] && echo "Running $script" && \
  /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "${SA_PASSWORD}" -d master -i "$script" -N -C
done

# Keep SQL Server in foreground
wait