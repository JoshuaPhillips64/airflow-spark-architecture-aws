#!/bin/bash

# Downloading and installing Anaconda
echo "Downloading Anaconda..."
wget https://repo.anaconda.com/archive/Anaconda3-2021.11-Linux-x86_64.sh -O /root/Anaconda3-2021.11-Linux-x86_64.sh
echo "Running Anaconda script..."
bash /root/Anaconda3-2021.11-Linux-x86_64.sh -b -p /root/anaconda
rm /root/Anaconda3-2021.11-Linux-x86_64.sh

# Initializing Conda (adjusting for non-interactive shell)
/root/anaconda/bin/conda init bash
source /root/.bashrc
/root/anaconda/bin/conda update -y conda
echo "Installed Conda version:"
/root/anaconda/bin/conda --version

# Updating and installing packages
yum update -y
yum install -y git docker

# Starting and configuring Docker
service docker start
groupadd docker
usermod -aG docker ec2-user

# Installing Docker Compose
mkdir -p /root/bin
wget https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -O /root/bin/docker-compose
chmod +x /root/bin/docker-compose
echo 'export PATH=/root/bin:${PATH}' >> /root/.bashrc

# Clone the GitHub repository
cd /root
git clone https://github.com/JoshuaPhillips64/airflow-spark-architecture-aws.git
