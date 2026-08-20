resource "aws_ecs_cluster" "backend" {
  name = "${local.name_prefix}-ecs-cluster"
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${local.name_prefix}-backend"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.backend_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  container_definitions = jsonencode([
    {
      name      = "${local.name_prefix}-backend"
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
          value = aws_db_instance.db.master_user_secret[0].secret_arn
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.db.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.db.port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_backend.name
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
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_migration_cpu
  memory                   = var.backend_migration_memory
  container_definitions = jsonencode([
    {
      name      = "${local.name_prefix}-backend-migration"
      image     = "${aws_ecr_repository.backend.repository_url}:${var.backend_image_tag}"
      essential = true
      command = [
        "node",
        "backend/dist/scripts/migrate.js"
      ]
      environment = [
        {
          name  = "DB_SECRET_ARN"
          value = aws_db_instance.db.master_user_secret[0].secret_arn
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.db.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.db.port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_backend.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "backend-migration"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "backend" {
  name            = "${local.name_prefix}-backend-service"
  cluster         = aws_ecs_cluster.backend.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.backend_desired_count
  launch_type     = "FARGATE"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.backend.id]
    subnets          = aws_subnet.private[*].id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "${local.name_prefix}-backend"
    container_port   = var.backend_port
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }

  depends_on = [
    aws_lb_listener.backend,
    aws_iam_role_policy_attachment.ecs_task_execution,
    aws_iam_role_policy_attachment.backend_task_read_db_secret
  ]
}

