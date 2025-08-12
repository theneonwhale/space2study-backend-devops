output "app_secrets_arn" {
  description = "ARN of the application secrets in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "mongodb_url_with_credentials" {
  description = "MongoDB connection string with user and password"
  value       = "mongodb+srv://${var.mongodb_username}:${var.mongodb_password}@${replace(var.mongodb_connection_string, "mongodb+srv://", "")}/${var.project_name}"
  sensitive   = true
}
