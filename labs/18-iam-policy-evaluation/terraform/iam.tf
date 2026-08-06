data "aws_iam_policy_document" "s3_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }
  }
}

data "aws_iam_policy_document" "s3_boundary" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.lab.arn}/allowed/*"
    ]
  }
}

resource "aws_iam_policy" "s3_boundary" {
  name   = "${var.project_name}-s3-boundary-policy"
  policy = data.aws_iam_policy_document.s3_boundary.json
}

resource "aws_iam_role" "s3_access" {
  name                 = "${var.project_name}-s3-access"
  assume_role_policy   = data.aws_iam_policy_document.s3_trust.json
  permissions_boundary = aws_iam_policy.s3_boundary.arn
}

data "aws_iam_policy_document" "s3_permissions" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.lab.arn}/allowed/*",
      "${aws_s3_bucket.lab.arn}/private/*",
    ]
  }
}

resource "aws_iam_policy" "s3_permissions" {
  name   = "${var.project_name}-s3-permissions"
  policy = data.aws_iam_policy_document.s3_permissions.json
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.s3_access.name
  policy_arn = aws_iam_policy.s3_permissions.arn
}

data "aws_iam_policy_document" "resource_permissions" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.lab.arn}/private/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.s3_access.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "resource_permissions" {
  bucket = aws_s3_bucket.lab.id
  policy = data.aws_iam_policy_document.resource_permissions.json
}
