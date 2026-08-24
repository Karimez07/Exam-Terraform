# récupère dynamiquement les zones de disponibilité
data "aws_availability_zones" "available" {}

# appel du module vpc qu'on va importer grâce à la commande terraform init, le lien du module vous fournit une documentation du module vpc "terraform-aws-modules/vpc/aws"
module "vpc" {
  source = "terraform-aws-modules/vpc/aws" 
  name                             = "${var.namespace}-vpc"
  cidr                             = "10.0.0.0/16"
  azs                              = data.aws_availability_zones.available.names
  private_subnets                  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets                   = ["10.0.101.0/24", "10.0.102.0/24"]
  create_database_subnet_group     = true
  enable_nat_gateway               = true
  single_nat_gateway               = true
}

# SG pour autoriser les connexions SSH depuis n'importe quel hôte
resource "aws_security_group" "HTTP" {
  name        = "${var.namespace}-allow_internet"
  description = "Autoriser le trafic HTTP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP depuis Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.namespace}-HTTP"
  }
}
