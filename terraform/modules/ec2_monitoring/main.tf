# Find the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 instance for monitoring
resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"

  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.monitoring.id]

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  iam_instance_profile = aws_iam_instance_profile.monitoring_profile.name

  tags = {
    Name        = "${var.project_name}-monitoring"
    Environment = var.environment
  }
}

# Elastic IP for monitoring
resource "aws_eip" "monitoring" {
  instance = aws_instance.monitoring.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-monitoring-eip"
    Environment = var.environment
  }
}

# IAM role for EC2 to discover other instances
resource "aws_iam_role" "monitoring_role" {
  name = "${var.project_name}-monitoring-role"

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

# IAM policy for EC2 discovery
resource "aws_iam_role_policy" "discovery_policy" {
  name = "${var.project_name}-discovery-policy"
  role = aws_iam_role.monitoring_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "ec2:DescribeInstances"
        Resource = "*"
      }
    ]
  })
}

# Instance profile
resource "aws_iam_instance_profile" "monitoring_profile" {
  name = "${var.project_name}-monitoring-profile"
  role = aws_iam_role.monitoring_role.name
}

# Security group for monitoring
resource "aws_security_group" "monitoring" {
  name_prefix = "${var.project_name}-monitoring-"
  description = "Security group for monitoring EC2 instance"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Grafana access
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Grafana access"
  }

  # Prometheus access
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Prometheus access"
  }

  # Loki access
  ingress {
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Loki access"
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
    Name        = "${var.project_name}-monitoring-sg"
    Environment = var.environment
  }
}
