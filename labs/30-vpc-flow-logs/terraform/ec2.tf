resource "aws_instance" "nginx" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.nginx.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/user-data.sh")
  user_data_replace_on_change = true
}
