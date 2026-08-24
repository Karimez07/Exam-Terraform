variable "namespace" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "database_subnet_group_name" {
  type = string
}
variable "database_security_group_id" {
  type = string
}

variable "db_name" {
  type = string
}
