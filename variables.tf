# VPC

variable "vpc_job_tracker_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_job_tracker_name" {
  description = "Name for the VPC"
  type        = string
}

# Subnets

variable "public_subnet_job_tracker_cidrs" {
  description = "CIDR blocks for the Public subnet"
  type        = list(string)
}

variable "private_subnet_job_tracker_cidrs" {
  description = "CIDR blocks for the Private subnet"
  type        = list(string)
}

variable "data_subnet_job_tracker_cidrs" {
  description = "CIDR blocks for data tier subnets"
  type        = list(string)
}

variable "availability_zones_job_tracker" {
  description = "AZs for the subnets"
  type        = list(string)
}

# Security Groups

variable "sg_1_alb_job_tracker" {
  description = "sg for alb"
  type        = string
}

variable "sg_2_ecs_job_tracker" {
  description = "sg for ecs"
  type        = string
}

# ALB 

variable "alb_job_tracker" {
  description = "alb load balancer for public subnet"
  type        = string
}

variable "target_group_alb" {
  description = "target group in the private subnets"
  type        = string
}


# IAM 

variable "ecs_role_pull" {
  description = "allows pulling your docker images from the ECR via pull policy"
  type        = string
}

variable "ecs_pull_policy" {
  description = "gives the policy to allow ECS execution task"
  type        = string

}

variable "ecs_instance_role" {
  description = "allows ec2 to work with ec2"
  type        = string
}

variable "ecs_instance_profile" {
  description = "instance profile for ecs"
  type        = string
}

# ECS

variable "ecs_cluster_job_tracker" {
  description = "value"
  type        = string

}

variable "ecs_job_tracker_task" {
  default = "task for ecs cluster"
  type    = string
}

variable "ecs_job_tracker_service" {
  description = "keep 2 task running, register with alb tg, put them in private subnets"
  type        = string
}

variable "ecs_launch_template" {
  description = "the launch template for ecs to go in ec2"
  type        = string

}