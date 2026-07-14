resource "aws_autoscaling_group" "ecs" {
  name             = "${var.project_name}-asg"
  min_size         = var.autoscaling_min_size
  max_size         = var.autoscaling_max_size
  desired_capacity = var.autoscaling_desired_capacity

  vpc_zone_identifier = aws_subnet.public[*].id

  health_check_type         = "EC2"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ecs-instance"
    propagate_at_launch = true
  }
}
