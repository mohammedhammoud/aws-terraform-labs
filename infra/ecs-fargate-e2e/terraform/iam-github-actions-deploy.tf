data "aws_iam_policy_document" "github_actions_deploy" {
  statement {
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:RunTask",
      "ecs:DescribeTasks",
      "ecs:UpdateService",
      "ecs:DescribeServices",
    ]
    resources = ["*"]
  }

  statement {
    actions = ["iam:PassRole"]

    resources = [
      aws_iam_role.ecs_task_execution.arn,
      aws_iam_role.backend_task.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    resources = [
      aws_ecr_repository.backend.arn,
    ]
  }
}

resource "aws_iam_policy" "github_actions_deploy" {
  name   = "${local.name_prefix}-github-actions-deploy"
  policy = data.aws_iam_policy_document.github_actions_deploy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = local.github_actions_apply_role_name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}
