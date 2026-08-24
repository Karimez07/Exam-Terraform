resource "aws_ebs_volume" "wordpress_data" {
  availability_zone = var.availability_zone
  size              = 10

  tags = {
    Name = "${var.namespace}-wordpress_data"
  }

resource "aws_volume_attachment" "liaison" {
  device_name = "/dev/sdf"
  volume_id = module.aws_ebs_volume.ebs_volume
  instance_id = var.instance_id
  type = "gp3"
  encrypted = true

  tags = {
    Name = "${var.namespace}-volume-attachment"
  }
}