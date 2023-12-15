resource "aws_lb" "ANP-ML-API" {
  name                             = "ANP-ML-API"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = data.aws_subnet_ids.subnets.ids
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = true
}

resource "aws_lb_target_group" "ANP-ML-API" {
  name                 = "ANP-ML-API"
  port                 = var.ANP-ML-API-TASK-PORT
  protocol             = "TCP"
  target_type          = "ip"
  vpc_id               = data.aws_vpc.main.id
  deregistration_delay = 300
  health_check {
    interval = 30
    protocol = "TCP"
  }
  stickiness {
    enabled = true
    type    = "source_ip"
  }
}

resource "aws_lb_listener" "ANP-ML-API" {
  load_balancer_arn = aws_lb.ANP-ML-API.arn
  port              = var.ANP-ML-API-TASK-PORT
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ANP-ML-API.arn
  }
  depends_on = [
    aws_lb.ANP-ML-API, aws_lb_target_group.ANP-ML-API
  ]
}