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
    sid = "FrontendBucketsReadOnly"

    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketOwnershipControls",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [
      for instance in values(local.ecs_ec2_ci_instances) :
      "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-${instance.name_prefix}-frontend"
    ]
  }

  statement {
    sid = "CloudFrontReadOnly"

    actions = [
      "cloudfront:GetCachePolicy",
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:GetOriginAccessControl",
      "cloudfront:GetOriginAccessControlConfig",
      "cloudfront:ListOriginAccessControls",
      "cloudfront:ListTagsForResource",
    ]

    resources = ["*"]
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
      "autoscaling:Describe*",
      "iam:GetOpenIDConnectProvider",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetInstanceProfile",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
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
      "ssm:GetParameter",
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
