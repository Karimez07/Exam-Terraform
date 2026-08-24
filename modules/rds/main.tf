resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "db_terraform"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "$USER_DB_AWS"
  password             = "$PWD_DB_AWS"
  availability_zone    = "eu-west-3"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  multi_az             = true
}
