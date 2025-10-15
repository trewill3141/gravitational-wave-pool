#!/bin/bash

# Permifrost permission application script
# This script applies permissions defined in permifrost.yml to Snowflake

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

echo "🚀 Applying Permifrost permissions..."

# Run permifrost with dry run first
echo "📋 Running dry run to preview changes..."
permifrost \
    --config-file "${PERMIFROST_CONFIG_FILE:-permifrost.yml}" \
    --account "${SNOWFLAKE_ACCOUNT}" \
    --user "${SNOWFLAKE_USER}" \
    --password "${SNOWFLAKE_PASSWORD}" \
    --role "${SNOWFLAKE_ROLE}" \
    --warehouse "${SNOWFLAKE_WAREHOUSE}" \
    --dry-run \
    --verbose

# Ask for confirmation
read -p "🤔 Do you want to apply these changes? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ Applying permissions..."
    permifrost \
        --config-file "${PERMIFROST_CONFIG_FILE:-permifrost.yml}" \
        --account "${SNOWFLAKE_ACCOUNT}" \
        --user "${SNOWFLAKE_USER}" \
        --password "${SNOWFLAKE_PASSWORD}" \
        --role "${SNOWFLAKE_ROLE}" \
        --warehouse "${SNOWFLAKE_WAREHOUSE}" \
        --verbose
    echo "✅ Permissions applied successfully!"
else
    echo "❌ Permission application cancelled."
    exit 1
fi
