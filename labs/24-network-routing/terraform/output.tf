output "vpc_id" {
  value = aws_vpc.test.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "public_ec2_public_ip" {
  value = aws_instance.public.public_ip
}

output "public_ec2_private_ip" {
  value = aws_instance.public.private_ip
}

output "private_ec2_private_ip" {
  value = aws_instance.private.private_ip
}