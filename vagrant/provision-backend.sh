#!/bin/bash

# Update package lists
sudo apt-get update

# Install dependencies
sudo apt-get install -y git curl
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential

# Install PM2
sudo npm install -g pm2

# Clone the backend repository if it doesn't exist
if [ ! -d "/home/vagrant/backend" ]; then
  git clone https://github.com/theneonwhale/space2study-backend-devops.git /home/vagrant/backend
fi

# Copy the environment file template
cp /vagrant/.env.backend /home/vagrant/backend/.env

# Install npm dependencies
cd /home/vagrant/backend
npm install

# Start the application with PM2
pm2 start npm --name "backend" -- run start

# Set up PM2 to start on boot
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u vagrant --hp /home/vagrant
