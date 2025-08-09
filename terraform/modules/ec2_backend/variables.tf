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

variable "mongodb_secret_arn" {
  description = "ARN of the MongoDB URL secret in AWS Secrets Manager"
  type        = string
}

variable "app_secrets_arn" {
  description = "ARN of the application secrets in AWS Secrets Manager"
  type        = string
}
