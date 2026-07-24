resource "aws_lb" "lab" {
  name               = "07-alb-autoscaling-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb.id]

  tags = {
    Name = "07-alb-autoscaling-alb"
  }
}

resource "aws_lb_target_group" "lab" {
  name        = "07-alb-autoscaling-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lab.id

  tags = {
    Name = "07-alb-autoscaling-tg"
  }
}

resource "aws_lb_listener" "lab" {
  load_balancer_arn = aws_lb.lab.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab.arn
  }
}

resource "aws_autoscaling_group" "web" {
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  vpc_zone_identifier       = aws_subnet.public[*].id
  target_group_arns         = [aws_lb_target_group.lab.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
}
