resource "aws_lb" "lab" {
  name               = "06-alb-ec2-basics-alb"
  internal           = false
  load_balancer_type = "application"

  subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups = [aws_security_group.alb.id]

  tags = {
    Name = "06-alb-ec2-basics-alb"
  }
}

resource "aws_lb_target_group" "lab" {
  name        = "06-alb-ec2-basics-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lab.id
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.lab.arn
  target_id        = aws_instance.web.id
  port             = 80
}

# HTTP is intentional for this local learning lab
# In Production, public ALB traffic should use HTTPS
resource "aws_lb_listener" "lab" {
  load_balancer_arn = aws_lb.lab.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab.arn
  }
}


