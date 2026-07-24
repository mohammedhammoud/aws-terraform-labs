resource "aws_security_group" "alb" {
  name   = "07-alb-autoscaling-alb-sg"
  vpc_id = aws_vpc.lab.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "07-alb-autoscaling-alb-sg"
  }
}

resource "aws_security_group" "ec2" {
  name   = "07-alb-autoscaling-ec2-sg"
  vpc_id = aws_vpc.lab.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "07-alb-autoscaling-ec2-sg"
  }
}
