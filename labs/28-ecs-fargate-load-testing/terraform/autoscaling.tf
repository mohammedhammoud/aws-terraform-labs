resource "aws_appautoscaling_target" "ecs" {
  min_capacity       = 1
  max_capacity       = 5
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "requests" {
  name               = "${var.project_name}-requests"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 100

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"

      resource_label = "${aws_lb.main.arn_suffix}/${aws_lb_target_group.main.arn_suffix}"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
