resource "aws_instance" "web" {
  ami           = var.ec2_ami
  instance_type = var.ec2_instance_type

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
set -eux

echo "hello from 05-vpc-basics" > /tmp/index.html
cd /tmp
python3 -m http.server 80 > /tmp/http.log 2>&1 &
EOF

  tags = {
    Name = "05-vpc-basics-web"
  }
}
