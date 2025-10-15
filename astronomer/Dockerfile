# Astronomer Airflow Dockerfile
# Based on Astronomer's ap-airflow image

FROM quay.io/astronomer/ap-airflow:2.7.1-onbuild

# Set environment variables
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor
ENV AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=true
ENV AIRFLOW__CORE__LOAD_EXAMPLES=false
ENV AIRFLOW__API__AUTH_BACKENDS=airflow.api.auth.backend.basic_auth

# Install additional Python packages
COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

# Copy DBT project
COPY dbt/ /usr/local/airflow/dbt/

# Copy custom plugins
COPY airflow/plugins/ /usr/local/airflow/plugins/

# Set working directory
WORKDIR /usr/local/airflow
