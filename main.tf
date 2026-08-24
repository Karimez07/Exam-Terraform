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
  db_host               = module.rds.database_address
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
}

module "rds" {
  source                     = "./modules/rds"
  namespace                  = var.namespace
  db_name                    = var.db_name
  db_username                = var.db_username
  db_password                = var.db_password
  database_subnet_group_name = module.networking.database_subnet_group_name
  database_security_group_id = module.networking.database_security_group_id
}

module "ebs" {
  source            = "./modules/ebs"
  namespace         = var.namespace
  instance_id       = module.ec2.instance_id
  availability_zone = module.ec2.availability_zone
}

output "wordpress_url" {
  description = "URL publique du site WordPress"
  value       = "http://${module.ec2.public_ip}"
}