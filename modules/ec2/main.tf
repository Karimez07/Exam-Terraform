#Créez une Data Source aws_ami pour sélectionner l'ami disponible dans votre région
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
# Configurer l'instance EC2 dans un sous-réseau public
resource "aws_instance" "ec2_public" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.web_security_group_id]
  user_data                   = file("install_wordpress.sh")

  tags = {
    "Name" = "${var.namespace}-EC2-PUBLIC"
  }
}
