resource "aws_security_group" "alb" {
  name   = "06-alb-ec2-basics-alb-sg"
  vpc_id = aws_vpc.lab.id

  # inbound
  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "06-alb-ec2-basics-alb-sg"
  }
}

resource "aws_security_group" "ec2" {
  name   = "06-alb-ec2-basics-ec2-sg"
  vpc_id = aws_vpc.lab.id

  # inbound
  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # outbound
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "06-alb-ec2-basics-ec2-sg"
  }
}
