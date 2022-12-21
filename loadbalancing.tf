# INTERNET FACING LOAD BALANCER

resource "aws_lb" "three_tier_lb" {
  name            = "three-tier-loadbalancer"
  security_groups = [aws_security_group.three_tier_lb_sg.id]
  subnets         = [
    "${aws_subnet.three_tier_public_subnets.0.id}",
    "${aws_subnet.three_tier_public_subnets.1.id}",
    "${aws_subnet.three_tier_public_subnets.2.id}",
  ]
  idle_timeout    = 400

  depends_on = [
    var.app_asg
  ]
}

resource "aws_lb_target_group" "three_tier_tg" {
  name     = "three-tier-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = aws_vpc.three_tier_vpc.id

  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "three_tier_lb_listener" {
  load_balancer_arn = aws_lb.three_tier_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.three_tier_tg.arn
  }
}