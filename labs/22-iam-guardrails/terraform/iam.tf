data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }
  }
}

resource "aws_iam_role" "test" {
  name               = "${var.project_name}-test"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

data "aws_iam_policy_document" "broad_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${aws_s3_bucket.test.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "broad_access_policy" {
  name   = "${var.project_name}-broad-access-policy"
  policy = data.aws_iam_policy_document.broad_access_policy.json
}

resource "aws_iam_role_policy_attachment" "broad_access_policy" {
  role       = aws_iam_role.test.name
  policy_arn = aws_iam_policy.broad_access_policy.arn
}

data "aws_iam_policy_document" "custom_policy" {
  statement {
    effect = "Deny"
    actions = [
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.test.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "custom_policy" {
  name   = "${var.project_name}-custom-policy"
  policy = data.aws_iam_policy_document.custom_policy.json
}

resource "aws_iam_role_policy_attachment" "custom_policy" {
  role       = aws_iam_role.test.name
  policy_arn = aws_iam_policy.custom_policy.arn
}
