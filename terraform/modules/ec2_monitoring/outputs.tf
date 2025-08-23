output "monitoring_public_ip" {
  description = "Public IP address of the monitoring EC2 instance"
  value       = aws_eip.monitoring.public_ip
}

output "monitoring_instance_id" {
  description = "ID of the monitoring EC2 instance"
  value       = aws_instance.monitoring.id
}

output "monitoring_security_group_id" {
  description = "ID of the monitoring security group"
  value       = aws_security_group.monitoring.id
}
