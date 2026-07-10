resource "aws_instance" "web" {
  ami           = var.ec2_ami
  instance_type = var.ec2_instance_type

  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = false

  user_data = <<-EOF
#!/bin/bash
set -eux

echo "hello from 06-alb-ec2-basics" > /tmp/index.html
cd /tmp
python3 -m http.server 80 > /tmp/http.log 2>&1 &
EOF

  tags = {
    Name = "06-alb-ec2-basics-web"
  }
}

