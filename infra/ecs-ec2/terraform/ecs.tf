resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  tags = {
    Name = "${local.name_prefix}-cluster"
  }
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${local.name_prefix}-backend"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.backend_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  container_definitions = jsonencode([
    {
      name      = "${local.name_prefix}-backend-container"
      image     = "${aws_ecr_repository.backend.repository_url}:${var.backend_image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = var.backend_port
          hostPort      = var.backend_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DB_SECRET_ARN"
          value = aws_db_instance.main.master_user_secret[0].secret_arn
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.main.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.main.port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "CORS_ORIGIN"
          value = "https://${aws_cloudfront_distribution.frontend.domain_name}"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs["backend"].name
          awslogs-region        = var.region
          awslogs-stream-prefix = "backend"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "backend_migration" {
  family                   = "${local.name_prefix}-backend-migration"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.backend_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_migration_memory
  container_definitions = jsonencode([
    {
      name      = "${local.name_prefix}-backend-migration-container"
      image     = "${aws_ecr_repository.backend.repository_url}:${local.backend_migration_image_tag}"
      essential = true
      command = [
        "node",
        "backend/dist/scripts/migrate.js"
      ]
      environment = [
        {
          name  = "DB_SECRET_ARN"
          value = aws_db_instance.main.master_user_secret[0].secret_arn
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.main.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.main.port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs["backend"].name
          awslogs-region        = var.region
          awslogs-stream-prefix = "backend-migration"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "backend" {
  name            = "${local.name_prefix}-service-backend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.backend_desired_count

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 150

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2.name
    weight            = 1
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    security_groups  = [aws_security_group.backend.id]
    subnets          = aws_subnet.private[*].id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "${local.name_prefix}-backend-container"
    container_port   = var.backend_port
  }

  lifecycle {
    # Deployment workflow owns these after bootstrap.
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }

  depends_on = [
    aws_ecs_cluster_capacity_providers.main,
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_task_execution,
    aws_iam_role_policy.backend_read_db_secret,
    aws_iam_role_policy_attachment.github_actions_deploy,
  ]

  tags = {
    Name = "${local.name_prefix}-ecs-backend"
  }
}

resource "aws_ecs_capacity_provider" "ec2" {
  name = "cp-${local.name_prefix}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_draining               = "DISABLED"
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status = "DISABLED"
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [
    aws_ecs_capacity_provider.ec2.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2.name
    weight            = 1
  }
}
