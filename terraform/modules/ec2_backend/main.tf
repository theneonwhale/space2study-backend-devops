# EC2 instance for backend
resource "aws_instance" "backend" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (us-east-1)
  instance_type = "t2.micro"              # Free tier

  key_name               = aws_key_pair.space2study.key_name
  vpc_security_group_ids = [aws_security_group.backend.id]

  # IAM role for accessing Secrets Manager
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # user_data removed; project setup will be manual

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
          var.app_secrets_arn
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
