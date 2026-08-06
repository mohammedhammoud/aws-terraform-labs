locals {
  role_2_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-role-2"
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }
  }
}

data "aws_iam_policy_document" "role_boundary_1" {
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:AttachRolePolicy"
    ]
    resources = [local.role_2_arn]
  }
}

resource "aws_iam_policy" "role_boundary_1" {
  name   = "${var.project_name}-role-boundary-1"
  policy = data.aws_iam_policy_document.role_boundary_1.json
}

data "aws_iam_policy_document" "role_boundary_2" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = ["arn:aws:s3:::*/*"]
  }
}

resource "aws_iam_policy" "role_boundary_2" {
  name   = "${var.project_name}-role-boundary-2"
  policy = data.aws_iam_policy_document.role_boundary_2.json
}

resource "aws_iam_role" "role_1" {
  name                 = "${var.project_name}-role-1"
  permissions_boundary = aws_iam_policy.role_boundary_1.arn
  assume_role_policy   = data.aws_iam_policy_document.trust.json
}

data "aws_iam_policy_document" "identity" {
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateRole",
    ]
    resources = [local.role_2_arn]
    condition {
      test     = "StringEquals"
      variable = "iam:PermissionsBoundary"
      values   = [aws_iam_policy.role_boundary_2.arn]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy"
    ]
    resources = [local.role_2_arn]
  }
}

resource "aws_iam_policy" "identity" {
  name   = "${var.project_name}-identity"
  policy = data.aws_iam_policy_document.identity.json
}

resource "aws_iam_role_policy_attachment" "role_1" {
  role       = aws_iam_role.role_1.name
  policy_arn = aws_iam_policy.identity.arn
}
