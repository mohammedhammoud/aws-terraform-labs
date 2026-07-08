locals {
  https_only_buckets = {
    lab  = aws_s3_bucket.lab
    logs = aws_s3_bucket.logs
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "01-s3-basics-logs"
  # Intentionally no access logging on the log bucket, makes no sense to create recursive logs.
}

resource "aws_s3_bucket" "lab" {
  bucket = "01-s3-basics"
}

resource "aws_s3_bucket_logging" "lab" {
  bucket        = aws_s3_bucket.lab.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}

resource "aws_s3_bucket_policy" "https_only" {
  for_each = local.https_only_buckets

  bucket = each.value.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "RestrictToTLSRequestsOnly"
      Action = "s3:*"
      Effect = "Deny"
      Resource = [
        each.value.arn,
        "${each.value.arn}/*"
      ]
      Condition = {
        Bool = {
          "aws:SecureTransport" = "false"
        }
      }
      Principal = "*"
    }]
  })
}
