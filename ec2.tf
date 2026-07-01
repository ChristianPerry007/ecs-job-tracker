# EC2 build for ECS

resource "aws_launch_template" "ecs_lt" {
  name          = var.ecs_launch_template
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = "t2.micro"


  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster_job_tracker.name} >> /etc/ecs/ecs.config
  EOF
  )

  network_interfaces {
    security_groups = [aws_security_group.sg2_ecs_job_tracker.id]
  }
}

# ASG 

resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = aws_subnet.private_subnets[*].id
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ecs_cp" {
  name = "job-tracker-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_cp" {
  cluster_name       = aws_ecs_cluster.ecs_cluster_job_tracker.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_cp.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_cp.name
    weight            = 1
  }
}