resource "aws_s3_bucket" "test" {
  bucket        = "${data.aws_caller_identity.current.account_id}-${var.project_name}-bucket"
  force_destroy = true
}

resource "aws_s3_object" "test" {
  bucket  = aws_s3_bucket.test.id
  key     = "tmp/test.txt"
  content = "This is a test file."
}

data "aws_iam_policy_document" "s3_test" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.test.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"] # The condition below will only allow the test role arn and block other roles
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_role.test.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "test" {
  bucket = aws_s3_bucket.test.id
  policy = data.aws_iam_policy_document.s3_test.json
}
