resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_user" "developer" {
  name = "developer"
}

resource "aws_iam_user_group_membership" "developer" {
  user = aws_iam_user.developer.name
  groups = [
    aws_iam_group.developers.name
  ]
}

resource "aws_iam_policy" "s3_read_only" {
  name = "s3-read-only-02-iam-basics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.lab.arn
      },
      {
        Sid    = "AllowReadObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.lab.arn}/*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "developers_s3_read_only" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.s3_read_only.arn
}

resource "aws_iam_role" "app_role" {
  name = "app-role-02-iam-basics"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "app_role_s3_read_only" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.s3_read_only.arn
}
