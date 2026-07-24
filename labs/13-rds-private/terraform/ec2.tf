resource "aws_instance" "db_client" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/scripts/ec2-user-data.sh", {
    db_endpoint = aws_db_instance.lab.address
    db_port     = var.db_port
    db_username = aws_db_instance.lab.username
    db_name     = aws_db_instance.lab.db_name
    db_password = var.db_password
  })

  tags = {
    Name = "${var.project_name}-db-client"
  }
}
