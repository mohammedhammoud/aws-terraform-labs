locals {
  ec2_user_data = <<-EOF
#!/bin/bash
set -eux

echo "hello from 25-network-sg-vs-nacl" > /tmp/index.html
cd /tmp
python3 -m http.server 80 > /tmp/http.log 2>&1 &
EOF
}

resource "aws_instance" "public" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  user_data                   = local.ec2_user_data
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2_public.id]
}
