resource "aws_instance" "private" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.ec2_private.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_s3_access.name
  depends_on = [
    aws_s3_object.test,
    aws_iam_role_policy.ec2_s3_access
  ]
  user_data = <<-EOF
#!/bin/bash

set -eux
aws s3 cp "s3://${aws_s3_bucket.test.bucket}/test.txt" /tmp/test.txt

CONTENT=$(cat /tmp/test.txt)

echo "success: read '$CONTENT' via vpc endpoint" > /tmp/result.txt

aws s3 cp /tmp/result.txt "s3://${aws_s3_bucket.test.bucket}/result.txt"
EOF

}
