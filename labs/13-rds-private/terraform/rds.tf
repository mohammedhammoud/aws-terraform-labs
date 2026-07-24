resource "aws_db_instance" "lab" {
  identifier = "db-${var.project_name}"

  engine         = var.db_engine
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  allocated_storage = 20

  db_subnet_group_name   = aws_db_subnet_group.lab.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false

  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-db"
  }
}

resource "aws_db_subnet_group" "lab" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}
