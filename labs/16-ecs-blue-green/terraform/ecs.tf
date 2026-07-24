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
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      name      = local.container.name
      image     = "nginx:alpine"
      essential = true
      cpu       = 256
      memory    = 256
      portMappings = [
        {
          containerPort = local.container.port
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
  name            = "${var.project_name}-ecs-service"
  cluster         = aws_ecs_cluster.lab.id
  task_definition = aws_ecs_task_definition.lab.arn
  desired_count   = var.desired_task_count
  launch_type     = "EC2"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.ec2.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = local.container.name
    container_port   = local.container.port
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_task_execution
  ]

  tags = {
    Name = "${var.project_name}-ecs-service"
  }
}
