output "alb_dns_name" {
  value = aws_lb.lab.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.lab.name
}

output "ecs_service_name" {
  value = aws_ecs_service.lab.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.lab.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.lab.arn
}
