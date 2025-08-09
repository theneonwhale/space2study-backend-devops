output "s3_bucket_name" {
  description = "S3 bucket name for frontend"
  value       = aws_s3_bucket.frontend.id
}

output "frontend_website_endpoint" {
  description = "S3 bucket website endpoint URL"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}
