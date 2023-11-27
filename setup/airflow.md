## Setup Airflow VM

![airflow](../images/airflow.jpg)

After running the terraform apply. We will setup airflow on docker in a dedicated compute instance. dbt is setup inside airflow.

- Establish SSH connection or connect through AWS console 

  ```bash
  ssh streamify-airflow
  ```

On Local machine - .pem file should be saved to folder where you are running local terminal
  ```bash
  ssh -i "streaming-architecture-key-pair.pem" ubuntu@<OUTPUT FROM TERRAFORM>
  ```

Once you connect, need to make sure the user-data script "vm_setup.sh" completes. You can check that with below. 
Should read "VM Setup Complete". If it says anything else - its still running. Should take about 10 minutes.
    
  ```bash
  sudo tail /var/log/cloud-init-output.log
  ```

After it has completed - Clone git repo

  ```bash
  cd ~ && git clone https://github.com/JoshuaPhillips64/airflow-spark-architecture-aws.git
  ```

- Start Airflow. (This shall take a few good minutes, grab a coffee!)

  ```bash
  bash ~/airflow-spark-architecture-aws/scripts/airflow_startup.sh && cd ~/airflow-spark-architecture-aws/airflow
  ```

- Airflow should be available on port `8080` a couple of minutes after the above setup is complete. Login with default username & password as **airflow**.

- Airflow will be running in detached mode. To see the logs from docker run the below command

  ```bash
  docker-compose --follow
  ```

- To stop airflow

  ```bash
  docker-compose down
  ```

### DAGs

The setup has two dags
- `load_songs_dag`
  - Trigger first and only once to load a onetime song file into BigQuery
![songs_dag](../images/songs_dag.png)

- `streamify_dag`
  - Trigger after `load_songs_dag` to make sure the songs table table is available for the transformations
  - This dag will run hourly at the 5th minute and perform transformations to create the dimensions and fact.
![streamify_dag](../images/streamify_dag.png)

  - DAG Flow -
    - We first create an external table for the data that was received in the past hour.
    - We then create an empty table to which our hourly data will be appended. Usually, this will only ever run in the first run.
    - Then we insert or append the hourly data, into the table.
    - And then, delete the external table.
    - Finally, run the dbt transformation, to create our dimensions and facts.

### dbt

The transformations happen using dbt which is triggered by Airflow. The dbt lineage should look something like this -

![img](../images/dbt.png)

Dimensions:
- `dim_artists`
- `dim_songs`
- `dim_datetime`
- `dim_location`
- `dim_users`

Facts:
- `fact_streams`
  - Partitioning:
    - Data is partitioned on the timestamp column by hour to provide faster data updates for a dashboard that shows data for the last few hours.

Finally, we create `wide_stream` view to aid dashboarding.