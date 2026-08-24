terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}
module "ec2" {
  source                = "./modules/ec2"
  namespace             = var.namespace
  public_subnet_id      = module.networking.public_subnet_ids[0]
  web_security_group_id = module.networking.web_security_group_id
}

module "rds" {
  source    = "./modules/rds"
  namespace = var.namespace
  db_name = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  database_subnet_group_name = module.networking.database_subnet_group_name
  database_security_group_id = module.networking.database_security_group_id
}