#!/bin/bash

echo "Welcome to Chromium Setup Script!"

# Update system packages
sudo apt update && sudo apt upgrade -y

# Check if Screen is installed
echo "Checking if Screen is installed..."
if ! command -v screen &> /dev/null; then
    echo "Screen is not installed. Installing Screen..."
    sudo apt install screen -y
else
    echo "Screen is already installed."
fi

# Check if Git is installed

echo "checking if git is installed..."
if ! command -v git &> /dev/null; then 
    echo "git is not installed. Installing git"
    sudo apt update && sudo apt install git -y
else
    echo " git is already installed"


# Check if Docker is installed
echo "Checking if Docker is installed..."
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt update && sudo apt install -y docker.io
else
    echo "Docker is already installed."
fi

docker --version

# Check if Docker Compose is installed
echo "Checking if Docker Compose is installed..."
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo apt install -y docker-compose
else
    echo "Docker Compose is already installed."
fi

# Get current timezone from system
realpath --relative-to /usr/share/zoneinfo /etc/localtime

# Create Chromium Directory
echo "Creating Chromium Directory..."
mkdir -p chromium
cd chromium

# Get custom ports from user or use default ones
read -p "Enter the port for HTTP (default 3010): " http_port
http_port=${http_port:-3010}
read -p "Enter the port for HTTPS (default 3011): " https_port
https_port=${https_port:-3011}

# Prompt for secure inputs
echo "Please enter the username for Chromium (CUSTOM_USER):"
read -p "Username: " CUSTOM_USER

echo "Please enter the password for Chromium (PASSWORD):"
read -s -p "Password: " PASSWORD
echo  # Newline after password input

# Create docker-compose.yaml file
echo "Creating docker-compose file..."
cat <<EOF > docker-compose.yaml
version: "3.7"
services:
  chromium:
    image: lscr.io/linuxserver/chromium:latest
    container_name: chromium
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - CUSTOM_USER=$CUSTOM_USER
      - PASSWORD=$PASSWORD
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London  # Replace with your timezone if necessary
      - CHROME_CLI=https://github.com/OctoetIx # optional
    volumes:
      - /root/chromium/config:/config
    ports:
      - "$http_port:3000"
      - "$https_port:3001"
    shm_size: "1gb"
    restart: unless-stopped
EOF

# Display docker-compose.yaml content for review
cat docker-compose.yaml

# Start the Chromium container
echo "Starting Chromium container..."
docker-compose up -d

# Display status
echo "Docker Chromium is now running."
echo "You can access it at http://<your-vps-ip>:$http_port"
git remote add origin https://github.com/OctoetIx/Chromium-script.git