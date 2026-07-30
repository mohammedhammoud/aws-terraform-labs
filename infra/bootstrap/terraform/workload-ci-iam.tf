data "aws_iam_policy_document" "workload_github_actions_apply_assume_role" {
  for_each = local.workload_ci_instances

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
      values   = [each.value.github_subject]
    }
  }
}

resource "aws_iam_role" "workload_github_actions_apply" {
  for_each = local.workload_ci_instances

  name               = each.value.apply_role_name
  assume_role_policy = data.aws_iam_policy_document.workload_github_actions_apply_assume_role[each.key].json
}

data "aws_iam_policy_document" "workload_github_actions_apply" {
  for_each = local.workload_ci_instances

  statement {
    sid = "TerraformStateBucket"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.main.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        each.value.state_key_prefix,
        "${each.value.state_key_prefix}*",
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

    resources = ["${aws_s3_bucket.main.arn}/${each.value.state_key_prefix}*"]
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
    sid = "KmsForRdsEncryption"

    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["rds.${var.region}.amazonaws.com"]
    }
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

    resources = [each.value.workload_role_arn_pattern]
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

    resources = [each.value.workload_policy_arn_pattern]
  }

  statement {
    sid = "ManageDeployPolicyAttachmentOnApplyRole"

    actions = [
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
    ]

    resources = [each.value.apply_role_arn]

    condition {
      test     = "ArnEquals"
      variable = "iam:PolicyARN"
      values   = [each.value.deploy_policy_arn]
    }
  }

  statement {
    sid = "ReadApplyRoleAttachments"

    actions = [
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
    ]

    resources = [each.value.apply_role_arn]
  }

  statement {
    sid = "ReadDeployPolicy"

    actions = ["iam:GetPolicy"]

    resources = [each.value.deploy_policy_arn]
  }

  statement {
    sid = "PassWorkloadRolesToEcs"

    actions   = ["iam:PassRole"]
    resources = [each.value.workload_role_arn_pattern]

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

resource "aws_iam_policy" "workload_github_actions_apply" {
  for_each = local.workload_ci_instances

  name   = each.value.apply_policy_name
  policy = data.aws_iam_policy_document.workload_github_actions_apply[each.key].json
}

resource "aws_iam_role_policy_attachment" "workload_github_actions_apply" {
  for_each = local.workload_ci_instances

  role       = aws_iam_role.workload_github_actions_apply[each.key].name
  policy_arn = aws_iam_policy.workload_github_actions_apply[each.key].arn
}
