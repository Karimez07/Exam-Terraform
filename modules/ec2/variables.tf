# environnement de déploiement
variable "namespace" {
  type = string
}
variable "public_subnet_id" {
  type = string
}

variable "web_security_group_id" {
  type = string
}