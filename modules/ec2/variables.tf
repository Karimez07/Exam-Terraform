# environnement de déploiement
variable "namespace" {
  type = string
}
# VPC
variable "vpc" {
  type = any
}
# id du groupe de sécurité public
variable "sg_pub_id" {
  type = any
}
