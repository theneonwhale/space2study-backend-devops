variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., prod, dev)"
  type        = string
}

variable "mongodb_password" {
  description = "MongoDB user password"
  type        = string
}

variable "mongodb_connection_string" {
  description = "MongoDB Atlas connection string"
  type        = string
}

variable "backend_public_ip" {
  description = "Public IP of the backend EC2 instance"
  type        = string
}

variable "frontend_url" {
  description = "Frontend S3 website endpoint"
  type        = string
}

variable "jwt_access_secret" {
  description = "JWT access secret"
  type        = string
}

variable "jwt_refresh_secret" {
  description = "JWT refresh secret"
  type        = string
}

variable "jwt_reset_secret" {
  description = "JWT reset secret"
  type        = string
}

variable "jwt_confirm_secret" {
  description = "JWT confirm secret"
  type        = string
}

variable "mail_user" {
  description = "Gmail user for sending emails"
  type        = string
}

variable "gmail_client_id" {
  description = "Gmail OAuth client ID"
  type        = string
}

variable "gmail_client_secret" {
  description = "Gmail OAuth client secret"
  type        = string
}

variable "gmail_refresh_token" {
  description = "Gmail OAuth refresh token"
  type        = string
}

variable "superadmin_firstname" {
  description = "Superadmin first name"
  type        = string
}

variable "superadmin_lastname" {
  description = "Superadmin last name"
  type        = string
}

variable "superadmin_email" {
  description = "Superadmin email"
  type        = string
}

variable "superadmin_password" {
  description = "Superadmin password"
  type        = string
}
