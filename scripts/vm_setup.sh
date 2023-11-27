#!/bin/bash

# Install Python 3.9.6
echo "Installing git, and docker..."

# Updating and installing packages
apt-get update -y
apt-get install -y gcc libssl-dev libbz2-dev libffi-dev zlib1g-dev git docker.io

# Starting and configuring Docker
systemctl start docker
# Add the Docker group and add user to it (replace 'ubuntu' with your username if different)
groupadd docker || true  # Ignores the error if the group already exists
usermod -aG docker ubuntu

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