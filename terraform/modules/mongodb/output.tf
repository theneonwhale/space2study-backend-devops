output "mongodb_cluster_name" {
  description = "MongoDB cluster name"
  value       = mongodbatlas_cluster.space2study.name
}

output "mongodb_connection_string" {
  description = "MongoDB connection string (sensitive)"
  value       = data.mongodbatlas_cluster.space2study.connection_strings[0].standard_srv
  sensitive   = true
}

output "mongodb_database_user" {
  description = "MongoDB database user name"
  value       = mongodbatlas_database_user.space2study_user.username
}

output "mongodb_database_password" {
  description = "MongoDB database user password (sensitive)"
  value       = random_password.mongodb_password.result
  sensitive   = true
}
