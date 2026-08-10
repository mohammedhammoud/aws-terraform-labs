output "vpc_id" {
  value = aws_vpc.test.id
}

output "private_ec2_private_ip" {
  value = aws_instance.private.private_ip
}

output "nat_public_ip" {
  value = aws_eip.nat.public_ip
}
