resource "aws_s3_bucket" "lab" {
  bucket = "04-ec2-basics"
}

resource "aws_s3_bucket_public_access_block" "lab" {
  bucket = aws_s3_bucket.lab.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "https_only" {
  bucket = aws_s3_bucket.lab.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "HttpsOnly"
        Action = "s3:*"
        Effect = "Deny"
        Resource = [
          aws_s3_bucket.lab.arn,
          "${aws_s3_bucket.lab.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
        Principal = "*"
      }
    ]
  })
}
