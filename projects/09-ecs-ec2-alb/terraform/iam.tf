resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-task-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-ec2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Floci does not currently provide arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role,
# so the lab uses an equivalent customer-managed policy.
resource "aws_iam_policy" "ecs_instance" {
  name = "${var.project_name}-ecs-instance"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RegisterContainerInstance",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:StartTelemetrySession",
          "ecs:UpdateContainerInstancesState",
          "ecs:SubmitContainerStateChange",
          "ecs:SubmitTaskStateChange"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ecs_instance.arn
}

# EC2 can't use a role directly so we need to create an instance profile
resource "aws_iam_instance_profile" "ecs" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2.name
}
