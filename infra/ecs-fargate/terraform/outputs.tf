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

output "frontend_ecs_service_name" {
  value = aws_ecs_service.frontend.name
}

output "backend_ecs_service_name" {
  value = aws_ecs_service.backend.name
}
