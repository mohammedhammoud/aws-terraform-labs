resource "aws_security_group" "ec2" {
  name   = "${var.project_name}-ec2-sg"
  vpc_id = aws_vpc.lab.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

resource "aws_security_group" "db" {
  name   = "${var.project_name}-db-sg"
  vpc_id = aws_vpc.lab.id

  ingress {
    security_groups = [aws_security_group.ec2.id]
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}
