variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., prod, dev)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "allowed_ip_addresses" {
  description = "List of allowed IP addresses for SSH access"
  type        = list(string)
}

variable "app_secrets_arn" {
  description = "ARN of the application secrets in AWS Secrets Manager"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the EC2 instance"
  type        = string
}

variable "monitoring_security_group_id" {
  description = "The ID of the monitoring instance's security group"
  type        = string
}
