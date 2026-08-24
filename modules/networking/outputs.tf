output "sg_pub_id" {
  value = aws_security_group.allow_internet.id
}
output "public_subnet_id" {
  value       = aws_subnet.public[*].id
  description = "The ID of the subnet."
}
output "public_subnet_cidrs" {
  value       = aws_subnet.public[*].cidr_block
  description = "CIDR blocks of the created public subnets."
}
