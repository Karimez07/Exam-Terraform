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
# appel du module ec2
module "ec2" {
  source     = "./modules/ec2"
