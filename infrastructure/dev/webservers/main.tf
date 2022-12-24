#  Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Use remote state to retrieve network data
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "group11-dev-private-bucket"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}


# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = "${local.prefix}-${var.env}"
  key          = "${var.env}key"
}

# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "../../../modules/globalvars"
}

# webserver EC2 instance
resource "aws_instance" "webserver" {
  count                       = var.ec2_count
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.private_subnet_ids[count.index]
  security_groups             = [aws_security_group.webserver_sg.id]
  associate_public_ip_address = false
  user_data = templatefile("${path.module}/install_httpd.sh.tpl",
    {
      env    = upper(var.env),
      prefix = upper(local.prefix)
    }
  )

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-webserver-${count.index + 1}"
    }
  )
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = local.key
  public_key = file("${var.env}key.pub")
}


# Security Group of webserver
resource "aws_security_group" "webserver_sg" {
  name        = "allow_http_ssh_webserver"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "http from bastion server"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.bastion_cidrs]
  }

  ingress {
    description = "ssh from Bastion server"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_cidrs]
  }

  ingress {
    description     = "http from alb"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-webserverSg"
    }
  )
}


# Bastion host EC2 instance
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[1]
  security_groups             = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-bastion"
    }
  )
}
# Security Group of Bastion host
resource "aws_security_group" "bastion_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "SSH from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_public_ip}/32", "${var.my_private_ip}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-bastionSg"
    }
  )
}


# alb module to attach   EC2 instances load balancer

module "alb" {
  source          = "../../../modules/loadbalancing"
  env             = var.env
  vpc_id          = data.terraform_remote_state.network.outputs.vpc_id
  security_groups = [aws_security_group.lb_sg.id]
  subnets         = data.terraform_remote_state.network.outputs.public_subnet_ids[*]
  prefix          = var.prefix
  default_tags    = var.default_tags
}

resource "aws_security_group" "lb_sg" {
  name        = "allow_http_lb"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description      = "http from internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "http from internet"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-albSg"
    }
  )
}

# Auto-Scaling Group module

module "asg" {
  source              = "../../../modules/autoscaling"
  default_tags        = var.default_tags
  env                 = var.env
  desired_capacity    = var.desired_capacity
  instance_type       = var.instance_type
  public_key          = aws_key_pair.web_key.key_name
  prefix              = var.prefix
  security_groups     = [aws_security_group.webserver_sg.id]
  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  lb_target_group_arn = module.alb.target_group_arns[0]
  vpc_zone_identifier = data.terraform_remote_state.network.outputs.private_subnet_ids[*]
}