variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
# MongoDB Atlas API Keys
variable "mongodb_atlas_public_key" {
  description = "MongoDB Atlas Public API Key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_private_key" {
  description = "MongoDB Atlas Private API Key"
  type        = string
  sensitive   = true
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

variable "jwt_access_secret" {
  description = "JWT access secret"
  type        = string
  sensitive   = true
}

variable "jwt_refresh_secret" {
  description = "JWT refresh secret"
  type        = string
  sensitive   = true
}

variable "jwt_reset_secret" {
  description = "JWT reset secret"
  type        = string
  sensitive   = true
}

variable "jwt_confirm_secret" {
  description = "JWT confirm secret"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = "space2study-key"
}
