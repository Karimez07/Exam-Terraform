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

# appel du module networking
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