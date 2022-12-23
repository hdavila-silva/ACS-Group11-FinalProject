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

# VPC CIDR range
variable "vpc_cidr" {
  default     = "10.100.0.0/16"
  type        = string
  description = "VPC for Dev Environment"
}

# Provision public subnets in Dev VPC
variable "public_cidr_blocks" {
  default     = ["10.100.1.0/24", "10.100.2.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs for Dev Environment"
}


# Provision private subnets in Dev VPC
variable "private_cidr_blocks" {
  default     = ["10.100.3.0/24", "10.100.4.0/24"]
  type        = list(string)
  description = "Private Subnet CIDRs for Dev Environment"
}

# Variable to signal the current environment 
variable "env" {
  default     = "Dev"
  type        = string
  description = "Environment"
}