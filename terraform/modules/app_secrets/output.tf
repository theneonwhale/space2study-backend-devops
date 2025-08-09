output "mongodb_secret_arn" {
  description = "ARN of the MongoDB URL secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.mongodb_url.arn
}

output "app_secrets_arn" {
  description = "ARN of the application secrets in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.app_secrets.arn
}
