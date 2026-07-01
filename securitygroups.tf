# SG 1 for ALB

resource "aws_security_group" "sg1_alb_job_tracker" {
  name        = var.sg_1_alb_job_tracker
  description = "Allow traffic to alb for sg 1"
  vpc_id      = aws_vpc.job_tracker_ecs_vpc.id

}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_in_alb_ipv4" {
  security_group_id = aws_security_group.sg1_alb_job_tracker.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_out_alb_ipv4" {
  security_group_id = aws_security_group.sg1_alb_job_tracker.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# SG 2 for ECS

resource "aws_security_group" "sg2_ecs_job_tracker" {
  name        = var.sg_2_ecs_job_tracker
  description = "Allow traffic to ecs for sg 2"
  vpc_id      = aws_vpc.job_tracker_ecs_vpc.id

}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_to_ecs" {
  security_group_id            = aws_security_group.sg2_ecs_job_tracker.id
  referenced_security_group_id = aws_security_group.sg1_alb_job_tracker.id
  from_port                    = 8000
  ip_protocol                  = "tcp"
  to_port                      = 8000
}

resource "aws_vpc_security_group_egress_rule" "ecs_allow_all_egress" {
  security_group_id = aws_security_group.sg2_ecs_job_tracker.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
