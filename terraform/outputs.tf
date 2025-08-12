output "backend_public_ip" {
  description = "Backend server public IP"
  value       = module.ec2_backend.backend_public_ip
}

output "backend_url" {
  description = "Backend server URL"
  value       = "http://${module.ec2_backend.backend_public_ip}:3000"
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

output "deployment_commands" {
  description = "Commands to deploy frontend and check backend"
  value = <<-EOT
    # Frontend Deployment:
    cd /path/to/your/frontend
    echo "VITE_API_BASE_PATH=http://${module.ec2_backend.backend_public_ip}:3000" > .env.production
    npm run build
    aws s3 sync ./dist s3://${module.s3_frontend.s3_bucket_name} --delete

    # Backend Check:
    ssh -i ~/.ssh/space2study-key ec2-user@${module.ec2_backend.backend_public_ip}
    docker ps
    docker logs $(docker ps -q)
  EOT
}
