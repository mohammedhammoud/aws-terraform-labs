data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "frontend_deploy_assume_role" {
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
      values = [
        "repo:${var.github_repository}:environment:${var.environment}",
      ]
    }
  }
}

resource "aws_iam_role" "frontend_deploy" {
  name               = "${local.name_prefix}-frontend-deploy"
  assume_role_policy = data.aws_iam_policy_document.frontend_deploy_assume_role.json
}

data "aws_iam_policy_document" "frontend_deploy" {
  statement {
    sid = "ReadFrontendBucket"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.frontend.arn,
    ]
  }

  statement {
    sid = "ManageFrontendObjects"

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.frontend.arn}/*",
    ]
  }

  statement {
    sid = "InvalidateFrontendDistribution"

    actions = [
      "cloudfront:CreateInvalidation",
    ]

    resources = [
      aws_cloudfront_distribution.frontend.arn,
    ]
  }
}

resource "aws_iam_policy" "frontend_deploy" {
  name   = "${local.name_prefix}-frontend-deploy"
  policy = data.aws_iam_policy_document.frontend_deploy.json
}

resource "aws_iam_role_policy_attachment" "frontend_deploy" {
  role       = aws_iam_role.frontend_deploy.name
  policy_arn = aws_iam_policy.frontend_deploy.arn
}
