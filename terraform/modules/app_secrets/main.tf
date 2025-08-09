# MongoDB URL secret
resource "aws_secretsmanager_secret" "mongodb_url" {
  name        = "${var.project_name}/mongodb-url"
  description = "MongoDB connection URL"
}

resource "aws_secretsmanager_secret_version" "mongodb_url" {
  secret_id = aws_secretsmanager_secret.mongodb_url.id
  secret_string = replace(
    var.mongodb_connection_string,
    "<password>",
    var.mongodb_password
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
    SERVER_URL              = "http://${var.backend_public_ip}:3000"
    CLIENT_URL              = var.frontend_url
    COOKIE_DOMAIN           = var.backend_public_ip
    JWT_ACCESS_SECRET       = var.jwt_access_secret
    JWT_ACCESS_EXPIRES_IN   = "15m"
    JWT_REFRESH_SECRET      = var.jwt_refresh_secret
    JWT_REFRESH_EXPIRES_IN  = "7d"
    JWT_RESET_SECRET        = var.jwt_reset_secret
    JWT_RESET_EXPIRES_IN    = "10m"
    JWT_CONFIRM_SECRET      = var.jwt_confirm_secret
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
