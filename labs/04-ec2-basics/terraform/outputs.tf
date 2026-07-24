output "ec2_lab" {
  value = {
    bucket_name           = aws_s3_bucket.lab.bucket
    instance_id           = aws_instance.lab.id
    instance_profile_name = aws_iam_instance_profile.ec2_profile.name
    role_arn              = aws_iam_role.ec2_role.arn
    policy_arn            = aws_iam_policy.s3_access.arn
    private_ip            = aws_instance.lab.private_ip
    public_ip             = aws_instance.lab.public_ip
    public_dns            = aws_instance.lab.public_dns
  }
}
