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

resource "aws_iam_role" "other" {
  name               = "${var.project_name}-other"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}
