# VPC   

resource "aws_vpc" "job_tracker_ecs_vpc" {
  cidr_block           = var.vpc_job_tracker_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_job_tracker_name
  }
}

