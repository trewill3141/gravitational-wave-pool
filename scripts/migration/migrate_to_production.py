#!/usr/bin/env python3
"""
Migration script for moving prototypes to production
Data Engineering Director - Production Migration Tool
"""

import os
import sys
import yaml
import shutil
from pathlib import Path
from datetime import datetime

class ProductionMigrator:
    def __init__(self, source_dir, target_dir):
        self.source_dir = Path(source_dir)
        self.target_dir = Path(target_dir)
        self.migration_log = []
    
    def log_migration(self, action, details):
        """Log migration actions"""
        timestamp = datetime.now().isoformat()
        log_entry = {
            'timestamp': timestamp,
            'action': action,
            'details': details
        }
        self.migration_log.append(log_entry)
        print(f"[{timestamp}] {action}: {details}")
    
    def validate_environment(self):
        """Validate that the environment is ready for migration"""
        self.log_migration("VALIDATION", "Starting environment validation")
        
        # Check if source directory exists
        if not self.source_dir.exists():
            raise FileNotFoundError(f"Source directory {self.source_dir} not found")
        
        # Check if target directory exists
        if not self.target_dir.exists():
            self.log_migration("CREATE", f"Creating target directory {self.target_dir}")
            self.target_dir.mkdir(parents=True, exist_ok=True)
        
        # Check for required files
        required_files = [
            'dbt/dbt_project.yml',
            'airflow/requirements.txt',
            'docker-compose.yml'
        ]
        
        for file_path in required_files:
            full_path = self.source_dir / file_path
            if not full_path.exists():
                raise FileNotFoundError(f"Required file {file_path} not found")
        
        self.log_migration("VALIDATION", "Environment validation completed successfully")
    
    def migrate_dbt_models(self):
        """Migrate DBT models and configurations"""
        self.log_migration("MIGRATION", "Starting DBT migration")
        
        dbt_source = self.source_dir / 'dbt'
        dbt_target = self.target_dir / 'dbt'
        
        if dbt_target.exists():
            shutil.rmtree(dbt_target)
        
        shutil.copytree(dbt_source, dbt_target)
        self.log_migration("MIGRATION", "DBT models migrated successfully")
    
    def migrate_airflow_dags(self):
        """Migrate Airflow DAGs and configurations"""
        self.log_migration("MIGRATION", "Starting Airflow migration")
        
        airflow_source = self.source_dir / 'airflow'
        airflow_target = self.target_dir / 'airflow'
        
        if airflow_target.exists():
            shutil.rmtree(airflow_target)
        
        shutil.copytree(airflow_source, airflow_target)
        self.log_migration("MIGRATION", "Airflow DAGs migrated successfully")
    
    def migrate_snowflake_configs(self):
        """Migrate Snowflake configurations"""
        self.log_migration("MIGRATION", "Starting Snowflake migration")
        
        snowflake_source = self.source_dir / 'snowflake'
        snowflake_target = self.target_dir / 'snowflake'
        
        if snowflake_target.exists():
            shutil.rmtree(snowflake_target)
        
        shutil.copytree(snowflake_source, snowflake_target)
        self.log_migration("MIGRATION", "Snowflake configs migrated successfully")
    
    def create_migration_report(self):
        """Create a migration report"""
        report_path = self.target_dir / 'migration_report.md'
        
        report_content = f"""# Migration Report
Generated: {datetime.now().isoformat()}

## Migration Summary
- Source: {self.source_dir}
- Target: {self.target_dir}
- Total Actions: {len(self.migration_log)}

## Migration Log
"""
        
        for entry in self.migration_log:
            report_content += f"- **{entry['timestamp']}**: {entry['action']} - {entry['details']}\n"
        
        with open(report_path, 'w') as f:
            f.write(report_content)
        
        self.log_migration("REPORT", f"Migration report created at {report_path}")
    
    def migrate(self):
        """Execute the full migration process"""
        try:
            self.validate_environment()
            self.migrate_dbt_models()
            self.migrate_airflow_dags()
            self.migrate_snowflake_configs()
            self.create_migration_report()
            
            print("\n✅ Migration completed successfully!")
            print(f"📊 Check migration_report.md for details")
            
        except Exception as e:
            print(f"\n❌ Migration failed: {str(e)}")
            sys.exit(1)

def main():
    if len(sys.argv) != 3:
        print("Usage: python migrate_to_production.py <source_dir> <target_dir>")
        sys.exit(1)
    
    source_dir = sys.argv[1]
    target_dir = sys.argv[2]
    
    migrator = ProductionMigrator(source_dir, target_dir)
    migrator.migrate()

if __name__ == "__main__":
    main()
