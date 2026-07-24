resource "aws_iam_policy" "s3_access" {
  name = "s3-access-04-ec2-basics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowPutObject"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.lab.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-role-04-ec2-basics"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_role_s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile-04-ec2-basics"
  role = aws_iam_role.ec2_role.name
}
