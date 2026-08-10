output "vpc_id" {
  value = aws_vpc.test.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "public_ec2_public_ip" {
  value = aws_instance.public.public_ip
}
