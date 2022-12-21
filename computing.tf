# LATEST AMI FROM PARAMETER STORE

data "aws_ssm_parameter" "three-tier-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "group11-key" {
  key_name   = "group11-key.pub"
  public_key = file("group11-key.pub")
}

# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR BASTION

resource "aws_launch_template" "three_tier_bastion" {
  name_prefix            = "three_tier_bastion"
  instance_type          = var.instance_type
  image_id               = data.aws_ssm_parameter.three-tier-ami.value
  vpc_security_group_ids = [aws_security_group.three_tier_bastion_sg.id]
  key_name               = aws_key_pair.group11-key.key_name

  tags = {
    Name = "three_tier_bastion"
  }
}

resource "aws_autoscaling_group" "three_tier_bastion" {
  name                = "three_tier_bastion"
  vpc_zone_identifier = [aws_subnet.three_tier_public_subnets.0.id]
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.three_tier_bastion.id
    version = "$Latest"
  }
}


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR FRONTEND APP TIER

resource "aws_launch_template" "three_tier_app" {
  name_prefix            = "three_tier_app"
  instance_type          = var.instance_type
  image_id               = data.aws_ssm_parameter.three-tier-ami.value
  vpc_security_group_ids = [aws_security_group.three_tier_frontend_app_sg.id]
  user_data              = file("${path.module}/install_httpd.sh")
  key_name               = aws_key_pair.group11-key.key_name

  tags = {
    Name = "three_tier_app"
  }
}

data "aws_lb_target_group" "three_tier_tg" {
  name = "three-tier-lb-tg-${substr(uuid(), 0, 3)}"
}

resource "aws_autoscaling_group" "three_tier_app" {
  name                = "three_tier_app"
  vpc_zone_identifier = aws_subnet.three_tier_private_subnets.*.id
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  target_group_arns = [data.aws_lb_target_group.three_tier_tg.arn]

  launch_template {
    id      = aws_launch_template.three_tier_app.id
    version = "$Latest"
  }
}


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR BACKEND

#resource "aws_launch_template" "three_tier_backend" {
#  name_prefix            = "three_tier_backend"
#  instance_type          = var.instance_type
#  image_id               = data.aws_ssm_parameter.three-tier-ami.value
#  vpc_security_group_ids = [var.backend_app_sg]
#  key_name               = var.key_name
#  user_data              = filebase64("install_node.sh")

#  tags = {
#    Name = "three_tier_backend"
#  }
#}

#resource "aws_autoscaling_group" "three_tier_backend" {
#  name                = "three_tier_backend"
#  vpc_zone_identifier = var.private_subnets
#  min_size            = 2
#  max_size            = 3
#  desired_capacity    = 2

#  launch_template {
#    id      = aws_launch_template.three_tier_backend.id
#    version = "$Latest"
#  }
#}

# AUTOSCALING ATTACHMENT FOR APP TIER TO LOADBALANCER

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.three_tier_app.id
  lb_target_group_arn    = var.lb_tg
}