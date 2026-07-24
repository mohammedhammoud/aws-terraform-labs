output "s3_bucket_name" {
  value = aws_s3_bucket.lab.bucket
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.lab.id
}

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.lab.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.lab.domain_name
}

output "origin_access_control_id" {
  value = aws_cloudfront_origin_access_control.lab.id
}
