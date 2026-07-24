output "db_instance_identifier" {
  value = aws_db_instance.lab.identifier
}

output "db_endpoint" {
  value = aws_db_instance.lab.address
}

output "db_port" {
  value = aws_db_instance.lab.port
}

output "db_publicly_accessible" {
  value = aws_db_instance.lab.publicly_accessible
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.lab.name
}

output "db_client_instance_id" {
  value = aws_instance.db_client.id
}

output "db_client_public_ip" {
  value = aws_instance.db_client.public_ip
}