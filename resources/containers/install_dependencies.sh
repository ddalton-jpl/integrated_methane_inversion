#!/bin/bash

# Ensure script is executed with root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Update package list
apt-get update

# Install sudo if not already installed
apt-get install -y sudo

# Remove existing Docker-related packages
docker_packages=("docker.io" "docker-doc" "docker-compose" "podman-docker" "containerd" "runc")
for pkg in "${docker_packages[@]}"; do
    sudo apt-get remove -y "$pkg"
done

# Add Docker's official GPG key
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the Docker repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update

# Install Docker packages
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker service
sudo service docker start

# Pull the Docker image from ECR
docker pull public.ecr.aws/w1q7j9l2/imi-docker-image:latest

# Run the Docker container with environment variables from file
docker run --env-file environment.env public.ecr.aws/w1q7j9l2/imi-docker-image:latest
