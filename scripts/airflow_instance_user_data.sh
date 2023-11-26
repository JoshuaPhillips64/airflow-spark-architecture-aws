#!/bin/bash

# Update and install necessary packages
sudo yum update -y
sudo yum install -y gi t unzip tar gzip gcc openssl-devel bzip2-devel libffi-devel

# Create directory to log outputs
sudo mkdir -p /var/log/my_lambda_layer_creation

# Install Poetry
sudo curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.5.0 python3 - >> /var/log/my_lambda_layer_creation/output.log 2>&1

# Update PATH to include the location where Poetry was installed
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Download, extract, and compile Python 3.9
cd /opt
sudo wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz
sudo tar xzf Python-3.9.6.tgz
cd Python-3.9.6
sudo ./configure --enable-optimizations
sudo make altinstall

# Create a link to python3.9
sudo ln -sf /usr/local/bin/python3.9 /usr/bin/python3

# Create directory for Airflow project
mkdir airflow_project
cd airflow_project

# Initialize a new Poetry project
poetry init --no-interaction >> /var/log/my_lambda_layer_creation/output.log 2>&1

PYPROJECT_FILE="pyproject.toml"

# Update the Python version and Apache Airflow dependency
sed -i '/\[tool.poetry.dependencies\]/a python = ">=3.8,<3.12"' $PYPROJECT_FILE
sed -i '/\[tool.poetry.dependencies\]/a apache-airflow = "^2.7.3"' $PYPROJECT_FILE

echo "Updated pyproject.toml:"

# Add Apache Airflow as a dependency
poetry add apache-airflow >> /var/log/my_lambda_layer_creation/output.log 2>&1

# Install dependencies
poetry install >> /var/log/my_lambda_layer_creation/output.log 2>&1

# Initialize the Airflow database
poetry run airflow db init >> /var/log/my_lambda_layer_creation/output.log 2>&1

# Create an admin user for Airflow
poetry run airflow users create \
    --username admin \
    --firstname Test \
    --lastname User \
    --role Admin \
    --email josh.l.phillips@me.com

# Update airflow.cfg file to make the webserver listen on all IPs
sed -i 's/load_examples = True/load_examples = False/' ~/airflow_project/airflow.cfg
sed -i 's/web_server_host = 127.0.0.1/web_server_host = 0.0.0.0/' ~/airflow_project/airflow.cfg >> /var/log/my_lambda_layer_creation/output.log 2>&1

# Start the Airflow webserver
nohup poetry run airflow webserver -p 8080 &

# Start the Airflow scheduler
nohup poetry run airflow scheduler &

# Start the Airflow worker (Celery Executor)
# Note: Only necessary if using the CeleryExecutor, not needed for LocalExecutor
# nohup poetry run airflow worker &

#check log with cat /var/log/my_lambda_layer_creation/output.log