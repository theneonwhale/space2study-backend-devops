#!/bin/bash

# Update package lists
sudo apt-get update

# Install dependencies
sudo apt-get install -y git curl
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential

# Install PM2
sudo npm install -g pm2

# Clone the frontend repository if it doesn't exist
if [ ! -d "/home/vagrant/frontend" ]; then
  git clone https://github.com/theneonwhale/space2study-frontend-devops.git /home/vagrant/frontend
fi

# Copy the environment file template
cp /vagrant/.env.frontend /home/vagrant/frontend/.env

# Install npm dependencies
cd /home/vagrant/frontend
npm install

# Start the application with PM2
pm2 start npm --name "frontend" -- run start

# Set up PM2 to start on boot
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u vagrant --hp /home/vagrant
