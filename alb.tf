# ALB Public 

resource "aws_lb" "job_tracker_public_alb" {
  name               = var.alb_job_tracker
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg1_alb_job_tracker.id]
  subnets            = aws_subnet.public_subnets[*].id
}

# ALB Target Group

resource "aws_lb_target_group" "job_tracker_private_tg" {
  name        = var.target_group_alb
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.job_tracker_ecs_vpc.id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# ALB Listener

resource "aws_lb_listener" "job_tracker_alb_listner" {
  load_balancer_arn = aws_lb.job_tracker_public_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.job_tracker_private_tg.arn

  }
}