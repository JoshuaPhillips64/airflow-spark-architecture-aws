# First-time build can take upto 10 mins.

# Use the official Apache Airflow image as a base
FROM apache/airflow:2.2.3

# Set the AIRFLOW_HOME environment variable
ENV AIRFLOW_HOME=/opt/airflow

# Run as root to install packages and manage system settings
USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends git curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

RUN cat /opt/airflow/poetry-installer-error-uk420_wn.log

# Copy only your pyproject.toml file into the image
# This file should define your Python dependencies
COPY pyproject.toml $AIRFLOW_HOME/

# Change working directory
WORKDIR $AIRFLOW_HOME

# Disable virtual environment creation by Poetry
# as Docker container itself provides isolation
RUN poetry config virtualenvs.create false

# Install dependencies using Poetry
# This will also create the poetry.lock file
RUN poetry install --no-dev

# Ref: https://airflow.apache.org/docs/docker-stack/recipes.html
SHELL ["/bin/bash", "-o", "pipefail", "-e", "-u", "-x", "-c"]

# Install AWS CLI for AWS operations within Airflow
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && aws --version

# Switch back to the Airflow user
USER $AIRFLOW_UID