variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "space2study"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "mongodb_atlas_org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
}

variable "allowed_ip_addresses" {
  description = "IP addresses allowed to access EC2"
  type        = list(string)
  default     = ["0.0.0.0/0"] # IP for SSH access
}

# Environment variables for the application
variable "superadmin_firstname" {
  description = "SuperAdmin first name"
  type        = string
  default     = "Super"
}

variable "superadmin_lastname" {
  description = "SuperAdmin last name"
  type        = string
  default     = "Admin"
}

variable "superadmin_email" {
  description = "SuperAdmin email"
  type        = string
}

variable "superadmin_password" {
  description = "SuperAdmin password"
  type        = string
  sensitive   = true
}

variable "mail_user" {
  description = "Gmail user for sending emails"
  type        = string
}

variable "gmail_client_id" {
  description = "Gmail OAuth Client ID"
  type        = string
}

variable "gmail_client_secret" {
  description = "Gmail OAuth Client Secret"
  type        = string
  sensitive   = true
}

variable "gmail_refresh_token" {
  description = "Gmail OAuth Refresh Token"
  type        = string
  sensitive   = true
}
