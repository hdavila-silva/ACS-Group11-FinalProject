# LATEST AMI FROM PARAMETER STORE

data "aws_ssm_parameter" "three-tier-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#data "aws_ami" "latest_amazon_linux" {
#  owners      = ["amazon"]
#  most_recent = true
#  filter {
#    name   = "name"
#    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#  }
#}

data "aws_ami" "ubuntu" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "group11-key" {
  key_name   = "group11"
  public_key = file("group11.pub")
}

# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR BASTION

resource "aws_launch_template" "three_tier_bastion" {
  name_prefix   = "three_tier_bastion"
  instance_type = var.instance_type
  image_id      = "ami-0574da719dca65348"
  #image_id               = data.aws_ssm_parameter.three-tier-ami.value
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
  name_prefix   = "three_tier_app"
  instance_type = var.instance_type
  image_id      = "ami-0574da719dca65348"
  #image_id               = data.aws_ssm_parameter.three-tier-ami.value
  vpc_security_group_ids = [aws_security_group.three_tier_frontend_app_sg.id]
  user_data              = filebase64("install_httpd.sh")
  key_name               = aws_key_pair.group11-key.key_name

  tags = {
    Name = "three_tier_app"
  }
}

#data "aws_lb_target_group" "three_tier_tg" {
#  name = "three-tier-lb-tg-${substr(uuid(), 0, 3)}"
#}

resource "aws_autoscaling_group" "three_tier_app" {
  name                = "three_tier_app"
  vpc_zone_identifier = aws_subnet.three_tier_private_subnets.*.id
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  target_group_arns = [aws_lb_target_group.three_tier_tg.arn]

  launch_template {
    id      = aws_launch_template.three_tier_app.id
    version = "$Latest"
  }
}

# AUTOSCALING ATTACHMENT FOR APP TIER TO LOADBALANCER

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.three_tier_app.id
  lb_target_group_arn    = aws_lb_target_group.three_tier_tg.arn
}

# Create auto-scaling policy for scaling in
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "web_scale_in"
  autoscaling_group_name = aws_autoscaling_group.three_tier_app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 900
}

# Create cloud watch alarm to scale in if cpu util load is below 5%
resource "aws_cloudwatch_metric_alarm" "scale_in" {
  alarm_description   = "Monitors CPU utilization for Web ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]
  alarm_name          = "web_scale_in"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "5"
  evaluation_periods  = "2"
  period              = "60"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.three_tier_app.name
  }
}

# Create auto-scaling policy for scaling out
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "web_scale_out"
  autoscaling_group_name = aws_autoscaling_group.three_tier_app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
}

# Create cloud watch alarm to scale out if cpu util if the load is above 10%
resource "aws_cloudwatch_metric_alarm" "scale_out" {
  alarm_description   = "Monitors CPU utilization for Web ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
  alarm_name          = "web_scale_out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "60"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.three_tier_app.name
  }
}