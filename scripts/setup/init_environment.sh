#!/bin/bash

# Data Engineering Director - Environment Setup Script
# This script sets up the local development environment

set -e

echo "🚀 Setting up Data Engineering Director Environment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "⚠️  Please update .env with your actual credentials before running the pipeline."
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p logs
mkdir -p dbt/target
mkdir -p dbt/logs

# Set up DBT
echo "🔧 Setting up DBT..."
cd dbt
if [ ! -f "profiles.yml" ]; then
    echo "⚠️  DBT profiles.yml not found. Please configure your Snowflake connection."
fi

# Install DBT dependencies
echo "📦 Installing DBT dependencies..."
dbt deps

cd ..

# Build and start Docker containers
echo "🐳 Building and starting Docker containers..."
docker-compose build
docker-compose up -d

echo "✅ Environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env with your Snowflake credentials"
echo "2. Configure DBT profiles.yml"
echo "3. Access Airflow UI at http://localhost:8080"
echo "4. Run 'dbt run' to execute your models"
echo ""
echo "Default Airflow credentials:"
echo "Username: admin"
echo "Password: admin"
