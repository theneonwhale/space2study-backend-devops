terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "mongodbatlas" {
  # You'll need to set these environment variables:
  # export MONGODB_ATLAS_PUBLIC_KEY="your-public-key"
  # export MONGODB_ATLAS_PRIVATE_KEY="your-private-key"
}

# Create MongoDB Atlas Project
resource "mongodbatlas_project" "space2study" {
  name   = "${var.project_name}-${var.environment}"
  org_id = var.mongodb_atlas_org_id
}

# Create MongoDB Atlas Cluster (Free Tier M0)
resource "mongodbatlas_cluster" "space2study" {
  project_id   = mongodbatlas_project.space2study.id
  name         = "${var.project_name}-cluster"

  # Free tier configuration
  provider_name               = "TENANT"
  backing_provider_name       = "AWS"
  provider_region_name        = "US_EAST_1"
  provider_instance_size_name = "M0"

  # MongoDB version
  mongo_db_major_version = "7.0"
}

# Create database user
resource "mongodbatlas_database_user" "space2study_user" {
  username           = "${var.project_name}-user"
  password           = random_password.mongodb_password.result
  project_id         = mongodbatlas_project.space2study.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = var.project_name
  }
}

# Generate random password for MongoDB
resource "random_password" "mongodb_password" {
  length  = 16
  special = true
}

# IP Access List (allow from anywhere for now - restrict later)
resource "mongodbatlas_project_ip_access_list" "space2study" {
  project_id = mongodbatlas_project.space2study.id
  cidr_block = "0.0.0.0/0"
  comment    = "Allow access from anywhere (restrict in production)"
}

# Get connection string
data "mongodbatlas_cluster" "space2study" {
  project_id = mongodbatlas_project.space2study.id
  name       = mongodbatlas_cluster.space2study.name
  depends_on = [mongodbatlas_cluster.space2study]
}

# Security group for EC2 backend
resource "aws_security_group" "backend" {
  name_prefix = "${var.project_name}-backend-"
  description = "Security group for backend EC2 instance"

  # HTTP access for backend API
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Backend API access"
  }

  # SSH access (restrict to your IP in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip_addresses
    description = "SSH access"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # HTTP access (for Let's Encrypt)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-backend-sg"
    Environment = var.environment
  }
}

# Key pair for EC2 access
resource "aws_key_pair" "space2study" {
  key_name   = "${var.project_name}-key"
  public_key = file("~/.ssh/space2study-key.pub") # You'll need to generate this
}

# EC2 instance for backend
resource "aws_instance" "backend" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (us-east-1)
  instance_type = "t2.micro"              # Free tier

  key_name               = aws_key_pair.space2study.key_name
  vpc_security_group_ids = [aws_security_group.backend.id]

  # IAM role for accessing Secrets Manager
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    mongodb_secret_arn = aws_secretsmanager_secret.mongodb_url.arn
    app_secrets_arn    = aws_secretsmanager_secret.app_secrets.arn
    region             = var.aws_region
  }))

  tags = {
    Name        = "${var.project_name}-backend"
    Environment = var.environment
  }
}

# Elastic IP for backend
resource "aws_eip" "backend" {
  instance = aws_instance.backend.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-backend-eip"
    Environment = var.environment
  }
}

# S3 bucket for frontend hosting
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-frontend-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project_name}-frontend"
    Environment = var.environment
  }
}

# Random suffix for bucket name (S3 names must be globally unique)
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket public access configuration
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 bucket website configuration
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# S3 bucket policy for public read access
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

# Generate JWT secrets
resource "random_password" "jwt_access_secret" {
  length  = 64
  special = true
}

resource "random_password" "jwt_refresh_secret" {
  length  = 64
  special = true
}

resource "random_password" "jwt_reset_secret" {
  length  = 64
  special = true
}

resource "random_password" "jwt_confirm_secret" {
  length  = 64
  special = true
}

# MongoDB URL secret
resource "aws_secretsmanager_secret" "mongodb_url" {
  name        = "${var.project_name}/mongodb-url"
  description = "MongoDB connection URL"
}

resource "aws_secretsmanager_secret_version" "mongodb_url" {
  secret_id = aws_secretsmanager_secret.mongodb_url.id
  secret_string = replace(
    data.mongodbatlas_cluster.space2study.connection_strings[0].standard_srv,
    "<password>",
    random_password.mongodb_password.result
  )
}

# Application secrets
resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "${var.project_name}/app-secrets"
  description = "Application secrets"
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    NODE_ENV                = "production"
    SERVER_PORT             = "3000"
    SERVER_URL              = "http://${aws_eip.backend.public_ip}:3000"
    CLIENT_URL              = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
    COOKIE_DOMAIN           = aws_eip.backend.public_ip
    JWT_ACCESS_SECRET       = random_password.jwt_access_secret.result
    JWT_ACCESS_EXPIRES_IN   = "15m"
    JWT_REFRESH_SECRET      = random_password.jwt_refresh_secret.result
    JWT_REFRESH_EXPIRES_IN  = "7d"
    JWT_RESET_SECRET        = random_password.jwt_reset_secret.result
    JWT_RESET_EXPIRES_IN    = "10m"
    JWT_CONFIRM_SECRET      = random_password.jwt_confirm_secret.result
    JWT_CONFIRM_EXPIRES_IN  = "24h"
    MAIL_USER               = var.mail_user
    GMAIL_CLIENT_ID         = var.gmail_client_id
    GMAIL_CLIENT_SECRET     = var.gmail_client_secret
    GMAIL_REFRESH_TOKEN     = var.gmail_refresh_token
    GMAIL_REDIRECT_URI      = "https://developers.google.com/oauthplayground"
    MAIL_FIRSTNAME          = "Space2Study"
    MAIL_LASTNAME           = "Team"
    MAIL_PASS               = "not_needed_with_oauth"
    SUPERADMIN_FIRSTNAME    = var.superadmin_firstname
    SUPERADMIN_LASTNAME     = var.superadmin_lastname
    SUPERADMIN_EMAIL        = var.superadmin_email
    SUPERADMIN_PASSWORD     = var.superadmin_password
  })
}

# IAM role for EC2 to access Secrets Manager
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Secrets Manager access
resource "aws_iam_role_policy" "secrets_policy" {
  name = "${var.project_name}-secrets-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.mongodb_url.arn,
          aws_secretsmanager_secret.app_secrets.arn
        ]
      }
    ]
  })
}

# Instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
