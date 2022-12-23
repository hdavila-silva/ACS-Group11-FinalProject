# Instance type
variable "instance_type" {
  default = {
    "prod"    = "t3.medium"
    "staging" = "t3.small"
    "dev"     = "t3.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}

# Default tags
variable "default_tags" {
  default = {
    "Owner" = "group11"
    "App"   = "web"
  }
}

# Prefix to identify resources
variable "prefix" {
  type    = string
  default = "group11"
}

# Variable to signal the current environment 
variable "env" {
  default     = "prod"
  type        = string
  description = "Deployment Environment"
}

variable "ec2_count" {
  type    = number
  default = "0"
}

# Cloud9 Public IP
variable "my_public_ip" {
  type        = string
  description = "Public IP of my Cloud9"
  default     = "34.203.75.236"
}

# Cloud9 Private IP
variable "my_private_ip" {
  type        = string
  description = "Private IP of my Cloud9"
  default     = "172.31.62.112"
}

# ASG Size for Dev Deployment
variable "desired_capacity" {
  type        = number
  description = "Desired capacity for ASG"
  default     = 3
}

# Bastion CIDR for EC2 SG
variable "bastion_cidrs" {
  type        = string
  default     = "10.250.2.0/24"
  description = "Bastion subnet range"
}