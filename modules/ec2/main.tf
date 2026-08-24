data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "ec2_public" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.web_security_group_id]
  user_data = templatefile("${path.root}/install_wordpress.sh", {
    db_host     = var.db_host
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
  })

  tags = {
    "Name" = "${var.namespace}-EC2-PUBLIC"
  }
}
