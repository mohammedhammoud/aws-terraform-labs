output "bucket_name" {
  value = aws_s3_bucket.lab.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.lab.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.lab.bucket_domain_name
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.lab.bucket_regional_domain_name
}
