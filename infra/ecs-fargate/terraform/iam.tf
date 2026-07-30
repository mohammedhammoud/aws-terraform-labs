resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.name_prefix}-task-execution"

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

resource "aws_iam_role" "backend_task" {
  name = "${local.name_prefix}-backend-task"

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

resource "aws_iam_role_policy" "backend_read_db_secret" {
  name = "${local.name_prefix}-backend-read-db-secret"
  role = aws_iam_role.backend_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = aws_db_instance.main.master_user_secret[0].secret_arn
      }
    ]
  })
}

data "aws_iam_policy_document" "github_actions_apply_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_actions_apply_subjects
    }
  }
}

resource "aws_iam_role" "github_actions_apply" {
  name               = "${local.name_prefix}-terraform"
  assume_role_policy = data.aws_iam_policy_document.github_actions_apply_assume_role.json
}

data "aws_iam_policy_document" "github_actions_apply" {
  statement {
    sid = "TerraformStateBucket"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [local.state_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        local.state_key_prefix,
        "${local.state_key_prefix}*",
      ]
    }
  }

  statement {
    sid = "TerraformStateObjects"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [local.state_object_arn]
  }

  statement {
    sid = "VpcAndNetworking"

    actions   = ["ec2:*"]
    resources = ["*"]
  }

  statement {
    sid = "Ecs"

    actions   = ["ecs:*"]
    resources = ["*"]
  }

  statement {
    sid = "Ecr"

    actions   = ["ecr:*"]
    resources = ["*"]
  }

  statement {
    sid = "Alb"

    actions   = ["elasticloadbalancing:*"]
    resources = ["*"]
  }

  statement {
    sid = "CloudWatchLogs"

    actions   = ["logs:*"]
    resources = ["*"]
  }

  statement {
    sid = "Rds"

    actions   = ["rds:*"]
    resources = ["*"]
  }

  statement {
    sid = "SecretsManager"

    actions   = ["secretsmanager:*"]
    resources = ["*"]
  }

  statement {
    sid = "ReadGithubOidcProvider"

    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviders",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ManageWorkloadRoles"

    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
    ]

    resources = [
      aws_iam_role.github_actions_apply.arn,
      aws_iam_role.ecs_task_execution.arn,
      aws_iam_role.backend_task.arn,
    ]
  }

  statement {
    sid = "ManageWorkloadPolicies"

    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:SetDefaultPolicyVersion",
      "iam:TagPolicy",
      "iam:UntagPolicy",
    ]

    resources = [
      local.github_actions_apply_policy_arn,
      aws_iam_policy.github_actions_deploy.arn,
    ]
  }

  statement {
    sid = "PassWorkloadTaskRolesToEcs"

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
    sid = "CreateServiceLinkedRoles"

    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values = [
        "ecs.amazonaws.com",
        "ecs.application-autoscaling.amazonaws.com",
        "elasticloadbalancing.amazonaws.com",
        "rds.amazonaws.com",
      ]
    }
  }

  statement {
    sid = "DeleteServiceLinkedRoles"

    actions = [
      "iam:DeleteServiceLinkedRole",
      "iam:GetServiceLinkedRoleDeletionStatus",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions_apply" {
  name   = "${local.name_prefix}-terraform"
  policy = data.aws_iam_policy_document.github_actions_apply.json
}

resource "aws_iam_role_policy_attachment" "github_actions_apply" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = aws_iam_policy.github_actions_apply.arn
}

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
      aws_ecr_repository.frontend.arn,
      aws_ecr_repository.backend.arn,
    ]
  }
}

resource "aws_iam_policy" "github_actions_deploy" {
  name   = "${local.name_prefix}-github-actions-deploy"
  policy = data.aws_iam_policy_document.github_actions_deploy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}
