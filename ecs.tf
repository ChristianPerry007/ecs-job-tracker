# ECS

resource "aws_ecs_cluster" "ecs_cluster_job_tracker" {
  name = var.ecs_cluster_job_tracker

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ECS Task

resource "aws_ecs_task_definition" "ecs_job_tracker_task" {
  family                   = var.ecs_job_tracker_task
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_pull_role_1.arn

  container_definitions = jsonencode([
    {
      name      = "job-tracker-container"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/job-tracker-api:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/job-tracker"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name  = "DB_HOST"
          value = aws_db_instance.job_tracker_rds_instance.address
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "DB_NAME"
          value = aws_db_instance.job_tracker_rds_instance.db_name
        },
        {
          name  = "DB_USER"
          value = aws_db_instance.job_tracker_rds_instance.username
        },
        {
          name  = "DB_PASSWORD"
          value = random_password.rds_password.result
        }
      ]
    }
  ])
}

# CloudWatch Log Group

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/job-tracker"
  retention_in_days = 7
}

# ECS Service

resource "aws_ecs_service" "ecs_job_tracker_service" {
  name                 = var.ecs_job_tracker_service
  cluster              = aws_ecs_cluster.ecs_cluster_job_tracker.id
  task_definition      = aws_ecs_task_definition.ecs_job_tracker_task.arn
  desired_count        = 2
  force_new_deployment = true

  network_configuration {
    subnets         = aws_subnet.private_subnets[*].id
    security_groups = [aws_security_group.sg2_ecs_job_tracker.id]

  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_cp.name
    weight            = 1
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.job_tracker_private_tg.arn
    container_name   = "job-tracker-container"
    container_port   = 8000
  }
}