resource "aws_s3_bucket" "lab" {
  bucket = var.project_name
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.lab.id
  key          = "index.html"
  source       = "${path.module}/../app/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../app/index.html")
}

resource "aws_s3_bucket_public_access_block" "lab" {
  bucket                  = aws_s3_bucket.lab.id
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
          "${aws_s3_bucket.lab.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
        Principal = "*"
      },
      {
        Sid    = "AllowCloudFrontRead"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.lab.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.lab.arn
          }
        }
      }
    ]
  })
}
