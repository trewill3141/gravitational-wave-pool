FROM apache/airflow:2.7.1-python3.10

USER root

# Install system dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         vim \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER airflow

# Copy requirements and install Python dependencies
COPY airflow/requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

# Copy DBT project
COPY dbt/ /opt/airflow/dbt/

# Set working directory
WORKDIR /opt/airflow
