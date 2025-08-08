output "backend_public_ip" {
  description = "Backend server public IP"
  value       = aws_eip.backend.public_ip
}

output "backend_url" {
  description = "Backend server URL"
  value       = "http://${aws_eip.backend.public_ip}:3000"
}

output "frontend_url" {
  description = "Frontend URL"
  value       = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
}

output "s3_bucket_name" {
  description = "S3 bucket name for frontend"
  value       = aws_s3_bucket.frontend.id
}

output "mongodb_cluster_name" {
  description = "MongoDB cluster name"
  value       = mongodbatlas_cluster.space2study.name
}

output "mongodb_connection_string" {
  description = "MongoDB connection string (sensitive)"
  value       = data.mongodbatlas_cluster.space2study.connection_strings[0].standard_srv
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to backend"
  value       = "ssh -i ~/.ssh/space2study-key ec2-user@${aws_eip.backend.public_ip}"
}

output "deployment_commands" {
  description = "Commands to deploy frontend and check backend"
  value = <<-EOT
    # Frontend Deployment:
    cd /path/to/your/frontend
    echo "VITE_API_BASE_PATH=http://${aws_eip.backend.public_ip}:3000" > .env.production
    npm run build
    aws s3 sync ./dist s3://${aws_s3_bucket.frontend.id} --delete

    # Backend Check:
    ssh -i ~/.ssh/space2study-key ec2-user@${aws_eip.backend.public_ip}
    docker ps
    docker logs $(docker ps -q)
  EOT
}
