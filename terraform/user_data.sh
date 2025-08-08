#!/bin/bash

# Log all output
exec > >(tee /var/log/user-data.log) 2>&1

echo "Starting user data script..."

# Update system
yum update -y

# Install required packages
yum install -y docker git jq unzip

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Start Docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Node.js (for building if needed)
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Create app directory
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Clone repository from terraform branch
echo "Cloning repository (terraform branch)..."
git clone --branch terraform https://github.com/theneonwhale/space2study-backend-devops.git .

# Create environment file from AWS Secrets Manager
echo "Getting secrets from AWS Secrets Manager..."

# Get application secrets
aws secretsmanager get-secret-value --secret-id ${app_secrets_arn} --region ${region} --query SecretString --output text | jq -r 'to_entries|map("\(.key)=\(.value)")|.[]' > .env.production

# Get MongoDB URL
MONGODB_URL=$(aws secretsmanager get-secret-value --secret-id ${mongodb_secret_arn} --region ${region} --query SecretString --output text)
echo "MONGODB_URL=$MONGODB_URL" >> .env.production

# Set proper ownership
chown -R ec2-user:ec2-user /home/ec2-user/app

# Create Docker Compose production file if it doesn't exist
if [ ! -f docker-compose.prod.yml ]; then
  echo "Creating docker-compose.prod.yml..."
  cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  backend:
    build: .
    ports:
      - "3000:3000"
    env_file:
      - .env.production
    restart: unless-stopped
    volumes:
      - ./logs:/app/logs
    environment:
      - NODE_ENV=production
EOF
fi

# Create Dockerfile if it doesn't exist
if [ ! -f Dockerfile ]; then
  echo "Creating Dockerfile..."
  cat > Dockerfile << 'EOF'
FROM node:18 AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production --ignore-scripts && npm cache clean --force

FROM node:18-slim
WORKDIR /app

RUN groupadd -r nodejs && useradd -r -g nodejs nodejs

COPY --from=builder /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .

RUN mkdir -p logs && chown nodejs:nodejs logs

USER nodejs

EXPOSE 3000

CMD ["npm", "run", "start:prod"]
EOF
fi

# Build and start the application
echo "Building and starting application..."
sudo -u ec2-user bash << 'EOF'
cd /home/ec2-user/app
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
EOF

# Create startup script for reboots
cat > /etc/systemd/system/space2study-backend.service << 'EOF'
[Unit]
Description=Space2Study Backend
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ec2-user/app
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down
TimeoutStartSec=0
User=ec2-user

[Install]
WantedBy=multi-user.target
EOF

systemctl enable space2study-backend.service

echo "User data script completed!"
