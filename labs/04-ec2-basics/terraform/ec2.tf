resource "aws_instance" "lab" {
  ami           = var.ec2_ami
  instance_type = var.ec2_instance_type

  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("${path.module}/../scripts/user-data.sh", {
    bucket_name = aws_s3_bucket.lab.bucket
  })

  tags = {
    Name = "04-ec2-basics"
  }
}