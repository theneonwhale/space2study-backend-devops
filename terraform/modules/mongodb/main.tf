terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Create MongoDB Atlas Project
resource "mongodbatlas_project" "space2study" {
  name   = "${var.project_name}-${var.environment}"
  org_id = var.mongodb_atlas_org_id
}

# Create MongoDB Atlas Cluster (Free Tier M0)
resource "mongodbatlas_cluster" "space2study" {
  project_id   = mongodbatlas_project.space2study.id
  name         = "${var.project_name}-cluster"

  # Free tier configuration
  provider_name               = "TENANT"
  backing_provider_name       = "AWS"
  provider_region_name        = "US_EAST_1"
  provider_instance_size_name = "M0"

  # MongoDB version
  mongo_db_major_version = "7.0"

  lifecycle {
    ignore_changes = [mongo_db_major_version]
  }
}

# Create database user
resource "mongodbatlas_database_user" "space2study_user" {
  username           = "${var.project_name}-user"
  password           = random_password.mongodb_password.result
  project_id         = mongodbatlas_project.space2study.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = var.project_name
  }
}

# Generate random password for MongoDB
resource "random_password" "mongodb_password" {
  length  = 16
  special = true
}

# IP Access List (allow from anywhere for now - restrict later)
resource "mongodbatlas_project_ip_access_list" "space2study" {
  project_id = mongodbatlas_project.space2study.id
  cidr_block = "${var.backend_public_ip}/32"
  comment    = "Allow access from backend server"
}

# Get connection string
data "mongodbatlas_cluster" "space2study" {
  project_id = mongodbatlas_project.space2study.id
  name       = mongodbatlas_cluster.space2study.name
  depends_on = [mongodbatlas_cluster.space2study]
}
