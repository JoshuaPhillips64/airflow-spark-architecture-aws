from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta

def process_data():
    # Spark job to process data and stream from Alpha Vantage API to S3
    pass

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2022, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG('my_dag', default_args=default_args, schedule_interval='@once') as dag:
    task = PythonOperator(
        task_id='process_data',
        python_callable=process_data,
    )
