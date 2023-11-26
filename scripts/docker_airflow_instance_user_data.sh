#!/bin/bash

# Set the script to exit immediately on error
set -e

# Log file setup. View log by running sudo cat /root/airflow_setup.log
LOG_FILE="/root/airflow_setup.log"
exec > >(tee -a ${LOG_FILE}) 2>&1
echo "Starting Airflow setup..."

# Update the system
echo "Updating system..."
yum update -y

# Install Docker
echo "Installing Docker..."
yum install docker -y
service docker start

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null 2>&1
chmod +x /usr/local/bin/docker-compose

# Install Python 3.9.6
echo "Installing Python 3.9.6..."
yum install gcc openssl-devel bzip2-devel libffi-devel zlib-devel -y > /dev/null 2>&1
wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz > /dev/null 2>&1
tar xzf Python-3.9.6.tgz > /dev/null 2>&1
cd Python-3.9.6 > /dev/null 2>&1
./configure --enable-optimizations > /dev/null 2>&1
make altinstall > /dev/null 2>&1
cd ..
ln -s /usr/local/bin/python3.9 /usr/bin/python3.9

# Set Python 3.9 as the default python version
echo "Setting Python 3.9 as the default version..."
update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1
update-alternatives --set python /usr/bin/python3.9

# Verify Python version
python --version

# Create a Docker Compose file for Airflow
echo "Creating Docker Compose file for Airflow..."
mkdir /root/airflow
cd /root/airflow
cat << EOF > docker-compose.yml
version: '3'
services:
  postgres:
    image: postgres:13
    environment:
      - POSTGRES_USER=airflow
      - POSTGRES_PASSWORD=airflow
      - POSTGRES_DB=airflow
    restart: always
    volumes:
      - ./postgres_data:/var/lib/postgresql/data
  webserver:
    image: apache/airflow:2.3.0-python3.9
    restart: always
    depends_on:
      - postgres
    environment:
      - AIRFLOW__CORE__EXECUTOR=LocalExecutor
      - AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow
      - AIRFLOW__CORE__FERNET_KEY=81HqDtbqAywKSOumSha3BhWNOdQ26slT6K0YaZeZyPs=
      - AIRFLOW__CORE__LOAD_EXAMPLES=False
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
      - ./plugins:/opt/airflow/plugins
    ports:
      - "8080:8080"
EOF

# Start Airflow
echo "Starting Airflow..."
docker-compose up -d

echo "Airflow setup completed. Please ensure that port 8080 is open in your EC2 instance's security group to access the Airflow web UI."