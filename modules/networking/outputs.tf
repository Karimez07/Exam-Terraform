output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "database_subnet_ids" {
  value = module.vpc.database_subnets
}

output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}

output "web_security_group_id" {
  value = aws_security_group.HTTP.id
}

output "database_security_group_id" {
  value = aws_security_group.database.id
}