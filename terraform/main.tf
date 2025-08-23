terraform {
  backend "s3" {
    bucket         = "space2study-backend-devops-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
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

provider "aws" {
  region = var.aws_region
}

provider "mongodbatlas" {
  public_key   = var.mongodb_atlas_public_key
  private_key  = var.mongodb_atlas_private_key
}

module "mongodb" {
  source                = "./modules/mongodb"
  project_name          = var.project_name
  environment           = var.environment
  mongodb_atlas_org_id  = var.mongodb_atlas_org_id
  backend_public_ip     = module.ec2_backend.backend_public_ip

  providers = {
    mongodbatlas = mongodbatlas
    random       = random
  }
}

module "s3_frontend" {
  source        = "./modules/s3_frontend"
  project_name  = var.project_name
  environment   = var.environment
}

module "ec2_backend" {
  source                       = "./modules/ec2_backend"
  project_name                 = var.project_name
  environment                  = var.environment
  aws_region                   = var.aws_region
  allowed_ip_addresses         = var.allowed_ip_addresses
  app_secrets_arn              = module.app_secrets.app_secrets_arn
  key_name                     = var.key_name
  monitoring_security_group_id = module.ec2_monitoring.monitoring_security_group_id
}

module "ec2_monitoring" {
  source       = "./modules/ec2_monitoring"
  project_name = var.project_name
  environment  = var.environment
  key_name     = var.key_name
}

module "app_secrets" {
  source                    = "./modules/app_secrets"
  project_name              = var.project_name
  environment               = var.environment
  mongodb_username          = module.mongodb.mongodb_database_user
  mongodb_password          = module.mongodb.mongodb_database_password
  mongodb_connection_string = module.mongodb.mongodb_connection_string
  backend_public_ip         = module.ec2_backend.backend_public_ip
  frontend_url              = module.s3_frontend.frontend_website_endpoint
  jwt_access_secret         = var.jwt_access_secret
  jwt_refresh_secret        = var.jwt_refresh_secret
  jwt_reset_secret          = var.jwt_reset_secret
  jwt_confirm_secret        = var.jwt_confirm_secret
  mail_user                 = var.mail_user
  gmail_client_id           = var.gmail_client_id
  gmail_client_secret       = var.gmail_client_secret
  gmail_refresh_token       = var.gmail_refresh_token
  superadmin_firstname      = var.superadmin_firstname
  superadmin_lastname       = var.superadmin_lastname
  superadmin_email          = var.superadmin_email
  superadmin_password       = var.superadmin_password
}
