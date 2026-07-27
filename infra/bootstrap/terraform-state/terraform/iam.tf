data "aws_iam_policy_document" "github_actions_terraform_apply" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.main.arn}/*"]
  }
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.main.arn]
  }
}

resource "aws_iam_policy" "github_actions_terraform_apply" {
  name   = "${local.name_prefix}-github-actions-terraform-apply"
  policy = data.aws_iam_policy_document.github_actions_terraform_apply.json
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform_apply" {
  role       = data.aws_iam_role.github_actions_apply.name
  policy_arn = aws_iam_policy.github_actions_terraform_apply.arn
}

data "aws_iam_policy_document" "github_actions_terraform_plan" {
  statement {
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.main.arn}/*"
    ]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${aws_s3_bucket.main.arn}/*.tflock"
    ]
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.main.arn]
  }
}

resource "aws_iam_policy" "github_actions_terraform_plan" {
  name   = "${local.name_prefix}-github-actions-terraform-plan"
  policy = data.aws_iam_policy_document.github_actions_terraform_plan.json
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform_plan" {
  role       = data.aws_iam_role.github_actions_plan.name
  policy_arn = aws_iam_policy.github_actions_terraform_plan.arn
}
