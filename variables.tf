variable "vpc_cidr" {
  type    = string
  default = "10.100.0.0/16"
}

variable "public_sn_count" {
  type    = number
  default = 3
}

variable "private_sn_count" {
  type    = number
  default = 3
}

variable "access_ip" {
  type    = string
  default = "54.166.138.10/32"
}

#variable "db_subnet_group" {
#  type = bool
#}

#variable "availabilityzone" {}

#variable "azs" {}