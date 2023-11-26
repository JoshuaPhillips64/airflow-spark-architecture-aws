#!/bin/bash
LOG_FILE="/var/log/airflow_setup.log"
AIRFLOW_HOME=~/airflow

# Function to handle errors
error_exit()
{
	echo "$1" | tee -a $LOG_FILE
	exit 1
}

# Update and upgrade system
echo "Updating system and installing dependencies..." | tee -a $LOG_FILE
sudo yum update -y >> $LOG_FILE 2>&1 || error_exit "Error: Failed to update system."
sudo yum install -y python3-pip python3-venv >> $LOG_FILE 2>&1 || error_exit "Error: Failed to install Python dependencies."

# Install PostgreSQL 13
echo "Installing PostgreSQL 13..." | tee -a $LOG_FILE
sudo amazon-linux-extras install postgresql13 -y >> $LOG_FILE 2>&1 || error_exit "Error: Failed to install PostgreSQL 13."

# Initialize PostgreSQL
echo "Initializing PostgreSQL..." | tee -a $LOG_FILE
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb || error_exit "Error: Failed to initialize PostgreSQL."
sudo systemctl start postgresql-13 || error_exit "Error: Failed to start PostgreSQL service."
sudo systemctl enable postgresql-13 || error_exit "Error: Failed to enable PostgreSQL service."

# Set PostgreSQL password for 'postgres' user (Change 'your_password' to your desired password)
echo "Setting PostgreSQL password..." | tee -a $LOG_FILE
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'your_password';" || error_exit "Error: Failed to set PostgreSQL password."

echo "Setting up PostgreSQL for Airflow..." | tee -a $LOG_FILE
sudo -u postgres psql -c "CREATE USER airflow WITH PASSWORD 'airflow';" || error_exit "Error: Failed to create PostgreSQL user."
sudo -u postgres psql -c "CREATE DATABASE airflow WITH OWNER airflow;" || error_exit "Error: Failed to create PostgreSQL database."

# Create and activate virtual environment
echo "Creating virtual environment for Airflow..." | tee -a $LOG_FILE
python3 -m venv $AIRFLOW_HOME/venv || error_exit "Error: Failed to create virtual environment."
source $AIRFLOW_HOME/venv/bin/activate || error_exit "Error: Failed to activate virtual environment."

# Install Apache Airflow with PostgreSQL support
echo "Installing Apache Airflow with PostgreSQL support..." | tee -a $LOG_FILE
pip install apache-airflow[postgres] >> $LOG_FILE 2>&1 || error_exit "Error: Failed to install Apache Airflow."

# Configure Airflow to use PostgreSQL
echo "Configuring Airflow to use PostgreSQL..." | tee -a $LOG_FILE
echo "sql_alchemy_conn = postgresql+psycopg2://airflow:airflow@localhost/airflow" >> $AIRFLOW_HOME/airflow.cfg

# Initialize Airflow
echo "Initializing Airflow database..." | tee -a $LOG_FILE
airflow db init >> $LOG_FILE 2>&1 || error_exit "Error: Failed to initialize Airflow database."

# Create Airflow user
echo "Creating Airflow user..." | tee -a $LOG_FILE
airflow users create \
    --username admin \
    --firstname FIRST_NAME \
    --lastname LAST_NAME \
    --role Admin \
    --email admin@example.com \
    --password admin >> $LOG_FILE 2>&1 || error_exit "Error: Failed to create Airflow user."

# Start Airflow webserver
echo "Starting Airflow webserver..." | tee -a $LOG_FILE
nohup airflow webserver --port 8080 >> $LOG_FILE 2>&1 & || error_exit "Error: Failed to start Airflow webserver."

# Start Airflow scheduler
echo "Starting Airflow scheduler..." | tee -a $LOG_FILE
nohup airflow scheduler >> $LOG_FILE 2>&1 & || error_exit "Error: Failed to start Airflow scheduler."

echo "Airflow setup completed." | tee -a $LOG_FILE