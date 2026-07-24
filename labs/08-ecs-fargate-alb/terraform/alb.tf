resource "aws_lb" "lab" {
  name               = var.project_name
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb.id]

  tags = {
    Name = var.project_name
  }
}

resource "aws_lb_target_group" "lab" {
  name        = "${var.project_name}-tg"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lab.id

  tags = {
    Name = "${var.project_name}-tg"
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
