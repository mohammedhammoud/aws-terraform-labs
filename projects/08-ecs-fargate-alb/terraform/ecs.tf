resource "aws_ecs_cluster" "lab" {
  name = "${var.project_name}-cluster"

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

resource "aws_ecs_task_definition" "lab" {
  family                   = "${var.project_name}-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions = jsonencode([
    {
      name  = local.container_name
      image = "nginx:alpine"
      portMappings = [
        {
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Name = "${var.project_name}-task"
  }
}

resource "aws_ecs_service" "lab" {
  name            = "${var.project_name}-ecs"
  cluster         = aws_ecs_cluster.lab.id
  task_definition = aws_ecs_task_definition.lab.arn
  desired_count   = var.desired_ecs_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.fargate.id]
    subnets          = aws_subnet.public[*].id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lab.arn
    container_name   = local.container_name
    container_port   = local.container_port
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer
    ]
  }

  depends_on = [
    aws_lb_listener.lab,
    aws_iam_role_policy_attachment.ecs_task_execution
  ]

  tags = {
    Name = "${var.project_name}-ecs-service"
  }
}
