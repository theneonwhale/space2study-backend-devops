output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "backend_public_ip" {
  description = "Backend server public IP"
  value       = module.ec2_backend.backend_public_ip
}

output "backend_url" {
  description = "Backend server URL"
  value       = "http://${module.ec2_backend.backend_public_ip}"
}

output "backend_secret_id" {
  description = "Backend secret id"
  value       = module.app_secrets.backend_secret_id
}

output "frontend_url" {
  description = "Frontend URL"
  value       = module.s3_frontend.frontend_website_endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket name for frontend"
  value       = module.s3_frontend.s3_bucket_name
}

output "mongodb_cluster_name" {
  description = "MongoDB cluster name"
  value       = module.mongodb.mongodb_cluster_name
}

output "mongodb_connection_string" {
  description = "MongoDB connection string (sensitive)"
  value       = module.mongodb.mongodb_connection_string
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to backend"
  value       = "ssh -i ~/.ssh/space2study-key ec2-user@${module.ec2_backend.backend_public_ip}"
}
