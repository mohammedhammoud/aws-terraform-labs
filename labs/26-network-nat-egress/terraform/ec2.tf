locals {
  ec2_user_data = <<-EOF
#!/bin/bash
set -eux
curl -s "https://webhook.site/2efba352-4a3d-4654-9e2d-66c25e11693f?source=nat-lab"
EOF
}

resource "aws_instance" "private" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  user_data                   = local.ec2_user_data
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.ec2_private.id]
}
