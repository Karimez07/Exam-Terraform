resource "aws_ebs_volume" "persistance_db" {
  availability_zone = "eu-west-3a"
  size              = 10

  tags = {
    Name = "persistance_db"
  }
}
