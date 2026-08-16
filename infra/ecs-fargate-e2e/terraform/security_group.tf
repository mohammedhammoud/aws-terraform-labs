resource "aws_security_group" "alb" {
  name   = "${local.name_prefix}-alb-sg"
  vpc_id = aws_vpc.main.id

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
}

resource "aws_security_group" "backend" {
  name   = "${local.name_prefix}-backend-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name   = "${local.name_prefix}-db-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    security_groups = [aws_security_group.backend.id]
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
  }
}
