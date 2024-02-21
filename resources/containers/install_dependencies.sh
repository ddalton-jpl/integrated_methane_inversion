#!/bin/bash

log_file="error_log.txt"

# Ensure script is executed with root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." | tee -a "$log_file"
  exit 1
fi

# Update package list and log errors
apt-get update 2>>"$log_file"

# Install sudo if not already installed
apt-get install -y sudo 2>>"$log_file"

# Remove existing Docker-related packages
docker_packages=("docker.io" "docker-doc" "docker-compose" "podman-docker" "containerd" "runc")
for pkg in "${docker_packages[@]}"; do
  sudo apt-get remove -y "$pkg" 2>>"$log_file"
done

# Add Docker's official GPG key
sudo apt-get install -y ca-certificates curl gnupg 2>>"$log_file"
sudo install -m 0755 -d /etc/apt/keyrings 2>>"$log_file"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>>"$log_file"
sudo chmod a+r /etc/apt/keyrings/docker.gpg 2>>"$log_file"

# Add the Docker repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 2>>"$log_file"
sudo apt-get update 2>>"$log_file"

# Install Docker packages
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>>"$log_file"

# Start Docker service
sudo service docker start