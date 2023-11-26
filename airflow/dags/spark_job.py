import requests
import datetime
from pyspark.sql import SparkSession
from pyspark.sql import Row

#%%

def fetch_data_from_alpha_vantage(api_key):
    url = f"https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=IBM&interval=1min&apikey={api_key}"
    response = requests.get(url)
    data = response.json()
    time_series_data = data.get('Time Series (1min)', {})
    return time_series_data

def process_data(data):
    rows = []
    for time, time_data in data.items():
        row = Row(timestamp=time, open=float(time_data['1. open']), high=float(time_data['2. high']),
                  low=float(time_data['3. low']), close=float(time_data['4. close']),
                  volume=int(time_data['5. volume']))
        rows.append(row)
    return rows

def write_to_s3(df, bucket_name):
    current_date = datetime.datetime.now().strftime("%Y-%m-%d")
    path = f"s3a://{bucket_name}/alpha_vantage_data_{current_date}.parquet"
    df.write.mode("overwrite").parquet(path)

def main():
    spark = SparkSession.builder.appName("AlphaVantageDataProcessing").getOrCreate()
    api_key = "YOUR_ALPHA_VANTAGE_API_KEY"  # Replace with your API key
    bucket_name = "your-s3-bucket-name"     # Replace with your S3 bucket name

    while True:
        raw_data = fetch_data_from_alpha_vantage(api_key)
        processed_data = process_data(raw_data)
        df = spark.createDataFrame(processed_data)
        write_to_s3(df, bucket_name)
        time.sleep(60)  # Wait for 1 minute before the next execution