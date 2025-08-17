#!/bin/bash

# Update package lists
sudo apt-get update

# Install MongoDB
sudo apt-get install -y mongodb

# Configure MongoDB to listen on all interfaces
sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/mongodb.conf

# Restart MongoDB to apply the changes
sudo systemctl restart mongodb

# Enable MongoDB to start on boot
sudo systemctl enable mongodb
