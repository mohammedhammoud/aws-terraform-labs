data "aws_iam_policy_document" "github_actions_plan_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_actions_plan_subjects
    }
  }
}

resource "aws_iam_role" "github_actions_plan" {
  name               = var.github_actions_plan_role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_plan_assume_role.json
}

data "aws_iam_policy_document" "github_actions_plan" {
  statement {
    sid = "TerraformStateBucketReadOnly"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.main.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        "${local.state_key_namespace}/*",
      ]
    }
  }

  statement {
    sid = "TerraformStateObjectsReadOnly"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.main.arn}/${local.state_key_namespace}/*",
    ]
  }

  statement {
    sid = "TerraformLockfiles"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${aws_s3_bucket.main.arn}/${local.state_key_namespace}/*/*.tflock",
      "${aws_s3_bucket.main.arn}/${local.state_key_namespace}/*/*/*.tflock",
    ]
  }

  statement {
    sid = "ReadOnlyDiscovery"

    actions = [
      "ec2:Describe*",
      "ecs:Describe*",
      "ecs:List*",
      "ecr:Describe*",
      "ecr:GetLifecyclePolicy",
      "ecr:ListTagsForResource",
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "elasticloadbalancing:Describe*",
      "iam:GetOpenIDConnectProvider",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListAttachedRolePolicies",
      "iam:ListOpenIDConnectProviders",
      "iam:ListPolicyVersions",
      "iam:ListRolePolicies",
      "logs:Describe*",
      "logs:GetLogGroupFields",
      "logs:ListTagsForResource",
      "rds:Describe*",
      "rds:ListTagsForResource",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions_plan" {
  name   = "${var.github_actions_plan_role_name}-policy"
  policy = data.aws_iam_policy_document.github_actions_plan.json
}

resource "aws_iam_role_policy_attachment" "github_actions_plan" {
  role       = aws_iam_role.github_actions_plan.name
  policy_arn = aws_iam_policy.github_actions_plan.arn
}
