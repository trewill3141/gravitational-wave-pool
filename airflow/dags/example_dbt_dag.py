from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator

# Default arguments
default_args = {
    'owner': 'data_engineering',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# DAG definition
dag = DAG(
    'dbt_snowflake_pipeline',
    default_args=default_args,
    description='Example DBT pipeline with Snowflake',
    schedule_interval=timedelta(days=1),
    catchup=False,
    tags=['dbt', 'snowflake', 'data_engineering'],
)

# DBT tasks
dbt_deps = BashOperator(
    task_id='dbt_deps',
    bash_command='cd /opt/airflow/dbt && dbt deps',
    dag=dag,
)

dbt_seed = BashOperator(
    task_id='dbt_seed',
    bash_command='cd /opt/airflow/dbt && dbt seed',
    dag=dag,
)

dbt_run = BashOperator(
    task_id='dbt_run',
    bash_command='cd /opt/airflow/dbt && dbt run',
    dag=dag,
)

dbt_test = BashOperator(
    task_id='dbt_test',
    bash_command='cd /opt/airflow/dbt && dbt test',
    dag=dag,
)

# Snowflake data quality check
snowflake_quality_check = SnowflakeOperator(
    task_id='snowflake_quality_check',
    sql='SELECT COUNT(*) FROM {{ params.table_name }}',
    snowflake_conn_id='snowflake_default',
    params={'table_name': 'your_table'},
    dag=dag,
)

# Task dependencies
dbt_deps >> dbt_seed >> dbt_run >> dbt_test >> snowflake_quality_check
