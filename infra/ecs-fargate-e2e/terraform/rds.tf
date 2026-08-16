resource "aws_db_subnet_group" "db" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.db[*].id
}

resource "aws_db_instance" "db" {
  identifier = "${local.name_prefix}-db"

  engine         = "postgres"
  instance_class = var.db_instance_class
  port           = 5432

  db_name                     = var.db_name
  username                    = var.db_username
  manage_master_user_password = true

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  # One-day retention to stay within the account's Free Tier restriction.
  backup_retention_period = 1

  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]

  # Single-AZ for this short-lived lab environment.
  multi_az = false

  skip_final_snapshot = true
  deletion_protection = false
}
