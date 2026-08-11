output "vpc_id" {
  value = aws_vpc.test.id
}

output "private_ec2_private_ip" {
  value = aws_instance.private.private_ip
}

output "s3_bucket" {
  value = aws_s3_bucket.test.bucket
}
