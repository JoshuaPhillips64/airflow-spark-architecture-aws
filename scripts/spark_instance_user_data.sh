#!/bin/bash

# Update System
sudo yum update -y

# Install Java
sudo yum install -y java-1.8.0-openjdk

# Download and Install Spark
wget https://archive.apache.org/dist/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz
tar xvf spark-3.2.1-bin-hadoop3.2.tgz
sudo mv spark-3.2.1-bin-hadoop3.2 /opt/spark

# Set Environment Variables
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

# Install Python3 and Set PySpark Python
sudo yum install -y python3

export PYSPARK_PYTHON=/usr/bin/python3

# Source bashrc
source ~/.bashrc

# Configure Log4j for Spark Logging
cp $SPARK_HOME/conf/log4j.properties.template $SPARK_HOME/conf/log4j.properties
sed -i 's/log4j.rootCategory=INFO, console/log4j.rootCategory=ERROR, console/g' $SPARK_HOME/conf/log4j.properties

# Setup Spark History Server
mkdir /tmp/spark-events
echo 'spark.eventLog.enabled true' >> $SPARK_HOME/conf/spark-defaults.conf
echo 'spark.eventLog.dir file:/tmp/spark-events' >> $SPARK_HOME/conf/spark-defaults.conf
echo 'spark.history.fs.logDirectory file:/tmp/spark-events' >> $SPARK_HOME/conf/spark-defaults.conf

# Install and Configure SSH
sudo yum install -y openssh-server openssh-clients
sudo systemctl enable sshd
sudo systemctl start sshd

# Start Spark History Server (Uncomment if required)
# $SPARK_HOME/sbin/start-history-server.sh

# Additional Dependencies (if required)
# sudo pip3 install [package-name]

# Start Spark Master and Worker Services
# (Uncomment and modify the following lines based on your cluster setup)
$SPARK_HOME/sbin/start-master.sh
$SPARK_HOME/sbin/start-slave.sh spark://master-url:7077

# Note: Consider adding additional configuration for monitoring tools (Ganglia, Prometheus, etc.),
# firewall/security groups, system tuning, and other dependencies as per your specific requirements.