output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "frontend_ecr_repository_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "backend_task_definition_arn" {
  value = aws_ecs_task_definition.backend.arn
}

output "frontend_task_definition_arn" {
  value = aws_ecs_task_definition.frontend.arn
}

output "backend_migration_task_definition_arn" {
  value = aws_ecs_task_definition.backend_migration.arn
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "backend_security_group_id" {
  value = aws_security_group.backend.id
}

output "frontend_ecs_service_name" {
  value = aws_ecs_service.frontend.name
}

output "backend_ecs_service_name" {
  value = aws_ecs_service.backend.name
}
