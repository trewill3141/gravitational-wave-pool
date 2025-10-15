# Permifrost Configuration

This directory contains Permifrost configuration files for managing Snowflake permissions as code.

## What is Permifrost?

Permifrost is a tool that allows you to manage Snowflake permissions using YAML configuration files. It provides:

- **Infrastructure as Code**: Define permissions in version-controlled YAML files
- **Consistency**: Ensure consistent permissions across environments
- **Auditability**: Track permission changes through git history
- **Automation**: Apply permissions automatically in CI/CD pipelines

## Files

- **`permifrost.yml`** - Main configuration file defining roles, users, and permissions
- **`requirements.txt`** - Python dependencies for Permifrost
- **`env.example`** - Environment variables template
- **`apply_permissions.sh`** - Script to apply permissions to Snowflake
- **`validate_permissions.sh`** - Script to validate current permissions

## Quick Start

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Configure Environment
```bash
cp env.example .env
# Edit .env with your Snowflake credentials
```

### 3. Validate Permissions
```bash
./validate_permissions.sh
```

### 4. Apply Permissions
```bash
./apply_permissions.sh
```

## Configuration Structure

### Databases and Schemas
```yaml
databases:
  - name: gravitational_wave_pool
    schemas:
      - name: raw
        tables:
          - name: events
```

### Warehouses
```yaml
warehouses:
  - name: development_warehouse
    size: X-SMALL
    auto_suspend: 60
```

### Roles and Permissions
```yaml
roles:
  - name: data_engineer
    warehouses: [development_warehouse, production_warehouse]
    schemas: [gravitational_wave_pool.raw, gravitational_wave_pool.staging]
    privileges: [USAGE, CREATE TABLE, CREATE VIEW]
```

### Users
```yaml
users:
  - name: data_engineer_1
    roles: [data_engineer]
    default_role: data_engineer
    default_warehouse: development_warehouse
```

## Best Practices

### 1. Role Hierarchy
- Create roles based on job functions, not individual users
- Use descriptive role names
- Grant minimal necessary permissions

### 2. Environment Management
- Use separate Permifrost configs for different environments
- Version control all permission changes
- Test changes in development before production

### 3. Security
- Never commit credentials to version control
- Use environment variables for sensitive data
- Regularly audit permissions

### 4. Documentation
- Document role purposes and permissions
- Keep configuration files well-commented
- Update documentation when making changes

## Common Commands

### Apply Permissions
```bash
permifrost --config-file permifrost.yml --account your_account --user your_user --password your_password --role ACCOUNTADMIN --warehouse your_warehouse
```

### Dry Run (Preview Changes)
```bash
permifrost --config-file permifrost.yml --account your_account --user your_user --password your_password --role ACCOUNTADMIN --warehouse your_warehouse --dry-run
```

### Validate Configuration
```bash
permifrost --config-file permifrost.yml --account your_account --user your_user --password your_password --role ACCOUNTADMIN --warehouse your_warehouse --validate
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure you're using ACCOUNTADMIN role
2. **Invalid Configuration**: Validate YAML syntax and structure
3. **Connection Issues**: Check Snowflake credentials and network access

### Debug Mode
```bash
permifrost --config-file permifrost.yml --account your_account --user your_user --password your_password --role ACCOUNTADMIN --warehouse your_warehouse --verbose
```

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: Apply Snowflake Permissions
on:
  push:
    branches: [main]
    paths: ['snowflake/permifrost/**']

jobs:
  apply-permissions:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: |
          cd snowflake/permifrost
          pip install -r requirements.txt
      - name: Apply permissions
        run: |
          cd snowflake/permifrost
          ./apply_permissions.sh
        env:
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
          SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
          SNOWFLAKE_ROLE: ${{ secrets.SNOWFLAKE_ROLE }}
          SNOWFLAKE_WAREHOUSE: ${{ secrets.SNOWFLAKE_WAREHOUSE }}
```

## Resources

- [Permifrost Documentation](https://github.com/grantorchard/permifrost)
- [Snowflake Access Control](https://docs.snowflake.com/en/user-guide/security-access-control.html)
- [Snowflake Best Practices](https://docs.snowflake.com/en/user-guide/security-best-practices.html)
