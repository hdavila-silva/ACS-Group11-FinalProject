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
  default = "34.224.95.27/32"
}

#variable "db_subnet_group" {
#  type = bool
#}

#variable "availabilityzone" {}

#variable "azs" {}

#### VARIABLES FOR COMPUTING

#variable "bastion_sg" {}
#variable "frontend_app_sg" {}
#variable "backend_app_sg" {}
#variable "private_subnets" {}
#variable "public_subnets" {}
#variable "key_name" {}
#variable "lb_tg_name" {
#  type = string
#  default = data.aws_lb_target_group.three_tier_tg
#}
variable "lb_tg" {
  type    = string
  default = "lb_tg"
}

variable "bastion_instance_count" {
  type    = number
  default = 1
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

### VARIABLES FOR LOADBALANCING

#variable "lb_sg" {}
#variable "public_subnets" {}
variable "app_asg" {
  type    = string
  default = "aws_autoscaling_group.three_tier_app"
}
variable "tg_port" {
  type    = number
  default = 80
}
variable "tg_protocol" {
  type    = string
  default = "HTTP"
}
#variable "vpc_id" {}
variable "listener_port" {
  type    = number
  default = 80
}
variable "listener_protocol" {
  type    = string
  default = "HTTP"
}
#variable "azs" {}