resource "aws_db_instance" "default" {
  allocated_storage      = 20
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = var.database_subnet_group_name
  vpc_security_group_ids = [var.database_security_group_id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = true
}
