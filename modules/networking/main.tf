# récupère dynamiquement les zones de disponibilité
data "aws_availability_zones" "available" {}

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  name                         = "${var.namespace}-vpc"
  version                      = "~> 5.0"
  cidr                         = "10.0.0.0/16"
  azs                          = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets               = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets             = ["10.0.1.0/24", "10.0.2.0/24"]
  create_database_subnet_group = true
}

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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.namespace}-HTTP"
  }
}

resource "aws_security_group" "database" {
  name        = "${var.namespace}-database"
  description = "Autoriser MySQL depuis le serveur web"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "MySQL depuis EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.HTTP.id]
  }

  tags = {
    Name = "${var.namespace}-database"
  }
}