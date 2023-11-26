# My Project

This project is designed to process data from the Alpha Vantage API, stream it to an S3 bucket, and perform data processing using Spark on an EMR cluster.

## Terraform Configuration

The Terraform configuration is used to provision the necessary AWS resources for the project. It creates a VPC, subnet, security group, and EC2 instance.

## Airflow DAG

The Airflow DAG is responsible for scheduling and executing the data processing tasks. It uses a PythonOperator to call the `process_data` function from the `spark_job.py` script.

## Spark Job

The Spark job is implemented in the `spark_job.py` script. It uses the SparkSession to process the data and stream it to the S3 bucket. The script reads the API and AWS keys from the `config.ini` file.

## Streaming Data from Alpha Vantage API

The `stream_data.py` script is responsible for continuously streaming data from the Alpha Vantage API and saving it as parquet files to the S3 bucket. The script reads the API key from the `config.ini` file.

## S3 Storage

The `s3_storage.py` script provides the functionality to save data to the S3 bucket. It reads the AWS keys from the `config.ini` file.

## Running the Project

1. Install Terraform, Apache Airflow, PySpark, and Boto3.
2. Configure the `config.ini` file with your API and AWS keys.
3. Run the Terraform commands to provision the AWS resources.
4. Initialize Airflow and start the scheduler and webserver.
5. Submit the Spark job using `spark-submit`.
6. Run the `stream_data.py` script to continuously stream data.