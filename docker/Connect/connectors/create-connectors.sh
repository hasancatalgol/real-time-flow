#!/bin/bash
set -e

echo "⏳ Waiting for Kafka Connect to be available on localhost:8083..."

# Wait until Kafka Connect REST endpoint is ready
until curl -s http://localhost:8083/connectors; do
  sleep 2
done

echo "✅ Kafka Connect REST API is ready"

# Loop through all JSON files and register them
for file in /kafka/connectors/*.json; do
  echo "🚀 Registering connector config: $file"
  
  if [ -f "$file" ]; then
    response=$(curl -s -o /dev/null -w "%{http_code}" \
      -X POST \
      -H "Content-Type: application/json" \
      --data @"$file" \
      http://localhost:8083/connectors)

    echo "📝 Response code: $response"

    if [ "$response" != "201" ] && [ "$response" != "409" ]; then
      echo "❌ Failed to register connector from $file"
    else
      echo "✅ Connector registered from $file"
    fi
  else
    echo "⚠️ Skipping $file (not a file)"
  fi
done
