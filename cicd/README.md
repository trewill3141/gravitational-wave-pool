# CI/CD Configuration

This directory contains CI/CD pipeline configurations for both GitHub Actions and Jenkins.

## Directory Structure

```
cicd/
├── github-actions/     # GitHub Actions workflows
├── jenkins/           # Jenkins pipeline configurations
└── README.md          # This file
```

## GitHub Actions

### Workflows

#### DBT Test and Deploy (`dbt-test.yml`)
- **Trigger**: Push to main/develop branches, changes to `dbt/**`
- **Actions**:
  - Install DBT dependencies
  - Run DBT debug, compile, and test
  - Deploy staging models on develop branch
  - Deploy all models on main branch

#### Airflow Deploy (`airflow-deploy.yml`)
- **Trigger**: Push to main branch, changes to `airflow/**` or `astronomer/**`
- **Actions**:
  - Install Astronomer CLI
  - Deploy to Astronomer Cloud/Software
  - Notify deployment status

#### Permifrost Apply (`permifrost-apply.yml`)
- **Trigger**: Push to main branch, changes to `snowflake/permifrost/**`
- **Actions**:
  - Install Permifrost
  - Validate current permissions
  - Apply permission changes

#### Docker Build (`docker-build.yml`)
- **Trigger**: Push to main branch, tags, changes to Dockerfiles
- **Actions**:
  - Build and push Docker images
  - Multi-architecture support
  - Cache optimization

### Required Secrets

Add these secrets to your GitHub repository:

```
SNOWFLAKE_ACCOUNT=your_account
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_ROLE=your_role
SNOWFLAKE_DATABASE=your_database
SNOWFLAKE_WAREHOUSE=your_warehouse
SNOWFLAKE_SCHEMA=your_schema
ASTRONOMER_TOKEN=your_astronomer_token
ASTRONOMER_ORGANIZATION=your_organization
ASTRONOMER_WORKSPACE=your_workspace
DOCKER_USERNAME=your_docker_username
DOCKER_PASSWORD=your_docker_password
```

## Jenkins

### Pipeline Configuration

#### Jenkinsfile
- **Type**: Pipeline job
- **Trigger**: SCM polling (every 5 minutes), timer (daily at 2 AM)
- **Branches**: main, develop
- **Features**:
  - Conditional execution based on changed files
  - Environment-specific deployments
  - Email notifications
  - Docker image building and pushing

#### Job Configuration (`job-config.xml`)
- **Build Discarder**: Keep 50 builds, 30 days
- **Triggers**: SCM polling, timer
- **Branches**: main, develop
- **Script Path**: `cicd/jenkins/Jenkinsfile`

#### Credentials (`credentials.xml`)
- **Snowflake**: Account, user, password, role, database, warehouse, schema
- **Astronomer**: API token
- **Docker**: Username and password
- **GitHub**: Username and token

### Jenkins Setup

1. **Install Required Plugins**:
   - Pipeline
   - Git
   - Docker Pipeline
   - Credentials Binding
   - Email Extension

2. **Configure Credentials**:
   - Import `credentials.xml` or manually add credentials
   - Update credential values for your environment

3. **Create Pipeline Job**:
   - Import `job-config.xml` or create new pipeline job
   - Set script path to `cicd/jenkins/Jenkinsfile`

## Pipeline Stages

### 1. DBT Pipeline
- **Test**: Compile and test all models
- **Deploy Staging**: Deploy staging models to develop environment
- **Deploy Production**: Deploy all models to production

### 2. Airflow Pipeline
- **Deploy**: Deploy DAGs to Astronomer
- **Environment**: Branch-based deployment

### 3. Permissions Pipeline
- **Validate**: Check current permissions
- **Apply**: Update Snowflake permissions

### 4. Docker Pipeline
- **Build**: Build Docker images
- **Push**: Push to Docker registry
- **Cache**: Optimize build caching

## Environment Strategy

### Development
- **Branch**: develop
- **DBT**: Staging models only
- **Airflow**: Development deployment
- **Permissions**: Validation only

### Production
- **Branch**: main
- **DBT**: All models
- **Airflow**: Production deployment
- **Permissions**: Full application

## Best Practices

### Security
- Use secrets management for credentials
- Rotate credentials regularly
- Limit access to production deployments
- Audit permission changes

### Monitoring
- Set up notifications for failures
- Monitor build times and resource usage
- Track deployment success rates
- Log all pipeline activities

### Maintenance
- Keep dependencies updated
- Review and update pipeline configurations
- Test changes in development first
- Document pipeline changes

## Troubleshooting

### Common Issues

1. **DBT Connection Failures**:
   - Check Snowflake credentials
   - Verify network connectivity
   - Validate warehouse availability

2. **Astronomer Deployment Failures**:
   - Verify Astronomer token
   - Check organization/workspace settings
   - Validate DAG syntax

3. **Permission Application Failures**:
   - Ensure ACCOUNTADMIN role
   - Check Permifrost configuration
   - Validate YAML syntax

4. **Docker Build Failures**:
   - Check Docker credentials
   - Verify Dockerfile syntax
   - Monitor registry quotas

### Debug Commands

```bash
# DBT debug
cd dbt && dbt debug

# Astronomer status
astro deployment list

# Permifrost validation
cd snowflake/permifrost && ./validate_permissions.sh

# Docker build test
docker build -t test-image .
```
