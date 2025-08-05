#!/bin/bash
# AWS Secrets Loading Script for Docker Compose

echo "Loading secrets from AWS Secrets Manager..."

# Install AWS CLI if not present
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    sudo dnf install -y awscli
fi

# Function to get secret value
get_secret() {
    aws secretsmanager get-secret-value \
        --secret-id "$1" \
        --query SecretString \
        --output text \
        --region eu-north-1
}

# Create .env.production with secrets
cat > .env.production << EOF
# Generated from AWS Secrets Manager
NODE_ENV=production
SERVER_PORT=3000
SERVER_URL=http://16.170.215.24:3000
CLIENT_URL=http://space2study-frontend-2025-v2.s3-website.eu-north-1.amazonaws.com
COOKIE_DOMAIN=16.170.215.24

# Database
MONGODB_URL=$(get_secret "prod/space2study/mongodb-url")

# JWT Secrets
JWT_ACCESS_SECRET=$(get_secret "prod/space2study/jwt-access")
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_SECRET=$(get_secret "prod/space2study/jwt-refresh")
JWT_REFRESH_EXPIRES_IN=7d
JWT_RESET_SECRET=$(get_secret "prod/space2study/jwt-reset")
JWT_RESET_EXPIRES_IN=10m
JWT_CONFIRM_SECRET=$(get_secret "prod/space2study/jwt-confirm")
JWT_CONFIRM_EXPIRES_IN=24h

# Email configuration (optional - not configured yet)
# MAIL_USER=
# GMAIL_CLIENT_ID=
# GMAIL_CLIENT_SECRET=
# GMAIL_REFRESH_TOKEN=
# GMAIL_REDIRECT_URI=https://developers.google.com/oauthplayground
# MAIL_FIRSTNAME=Space2Study
# MAIL_LASTNAME=Team
# MAIL_PASS=
EOF

echo ".env.production created with secrets from AWS Secrets Manager"
