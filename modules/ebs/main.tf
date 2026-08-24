resource "aws_ebs_volume" "wordpress_data" {
  availability_zone = var.availability_zone
  size              = 10
  type              = "gp3"
  encrypted         = true


  tags = {
    Name = "${var.namespace}-wordpress-data"
  }
}

resource "aws_volume_attachment" "liaison" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.wordpress_data.id
  instance_id = var.instance_id
  
}
