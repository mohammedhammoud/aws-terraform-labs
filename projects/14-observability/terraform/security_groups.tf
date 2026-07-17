resource "aws_security_group" "ec2" {
  vpc_id = aws_vpc.lab.id
  name   = "${var.project_name}-ec2-sg"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}
