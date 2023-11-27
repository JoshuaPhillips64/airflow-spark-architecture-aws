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
mkdir -p /usr/local/bin
wget https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -O /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Update PATH for all users
echo 'export PATH=/usr/local/bin:${PATH}' > /etc/profile.d/docker-compose.sh

# Install Poetry
echo "Installing Poetry..."
curl -sSL https://install.python-poetry.org | python3 -

# Ensure Poetry is available globally
ln -s /root/.local/bin/poetry /usr/local/bin/poetry

echo "VM setup complete!"

