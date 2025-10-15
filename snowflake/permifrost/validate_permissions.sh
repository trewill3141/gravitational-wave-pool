#!/bin/bash

# Permifrost permission validation script
# This script validates current permissions against permifrost.yml

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "❌ .env file not found. Please copy env.example to .env and configure your credentials."
    exit 1
fi

# Check if permifrost is installed
if ! command -v permifrost &> /dev/null; then
    echo "❌ Permifrost not found. Installing from requirements.txt..."
    pip install -r requirements.txt
fi

# Validate configuration file
if [ ! -f "${PERMIFROST_CONFIG_FILE:-permifrost.yml}" ]; then
    echo "❌ Configuration file not found: ${PERMIFROST_CONFIG_FILE:-permifrost.yml}"
    exit 1
fi

echo "🔍 Validating current permissions against Permifrost configuration..."

# Run permifrost validation
permifrost \
    --config-file "${PERMIFROST_CONFIG_FILE:-permifrost.yml}" \
    --account "${SNOWFLAKE_ACCOUNT}" \
    --user "${SNOWFLAKE_USER}" \
    --password "${SNOWFLAKE_PASSWORD}" \
    --role "${SNOWFLAKE_ROLE}" \
    --warehouse "${SNOWFLAKE_WAREHOUSE}" \
    --dry-run \
    --verbose

echo "✅ Permission validation completed!"
