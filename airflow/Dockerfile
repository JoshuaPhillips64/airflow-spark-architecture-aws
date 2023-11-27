# First-time build can take upto 10 mins.

FROM apache/airflow:2.5.2-python3.9

ENV AIRFLOW_HOME=/opt/airflow

USER root
# Update and upgrade the system packages, and install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git curl unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI for AWS operations within Airflow
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && aws --version

USER $AIRFLOW_UID
RUN pip install --upgrade pip
# git gcc g++ -qqq

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Ref: https://airflow.apache.org/docs/docker-stack/recipes.html

SHELL ["/bin/bash", "-o", "pipefail", "-e", "-u", "-x", "-c"]

WORKDIR $AIRFLOW_HOME

USER $AIRFLOW_UID