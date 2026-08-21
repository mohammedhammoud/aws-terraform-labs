data "aws_iam_policy_document" "ecs_task_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${local.name_prefix}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "backend_read_db_secret" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_db_instance.db.master_user_secret[0].secret_arn]
  }
}

resource "aws_iam_policy" "backend_read_db_secret" {
  name   = "${local.name_prefix}-db-secret-policy"
  policy = data.aws_iam_policy_document.backend_read_db_secret.json

}

data "aws_iam_policy_document" "backend_task_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "backend_task" {
  name               = "${local.name_prefix}-backend-task"
  assume_role_policy = data.aws_iam_policy_document.backend_task_policy.json
}

resource "aws_iam_role_policy_attachment" "backend_task_read_db_secret" {
  role       = aws_iam_role.backend_task.name
  policy_arn = aws_iam_policy.backend_read_db_secret.arn
}


