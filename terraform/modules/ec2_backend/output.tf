output "backend_instance_id" {
  description = "ID of the backend EC2 instance"
  value       = aws_instance.backend.id
}

output "backend_public_ip" {
  description = "Public IP of the backend EC2 instance (Elastic IP)"
  value       = aws_eip.backend.public_ip
}

output "backend_security_group_id" {
  description = "Security group ID for backend EC2 instance"
  value       = aws_security_group.backend.id
}
