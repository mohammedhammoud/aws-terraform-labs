output "alb_dns_name" {
  value = aws_lb.lab.dns_name
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.web.name
}

output "target_group_arn" {
  value = aws_lb_target_group.lab.arn
}
