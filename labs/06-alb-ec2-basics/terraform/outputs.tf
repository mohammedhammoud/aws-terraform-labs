output "alb_lab" {
  value = {
    alb_arn          = aws_lb.lab.arn
    alb_dns_name     = aws_lb.lab.dns_name
    target_group_arn = aws_lb_target_group.lab.arn
    instance_id      = aws_instance.web.id
    alb_sg_id        = aws_security_group.alb.id
    ec2_sg_id        = aws_security_group.ec2.id
    public_subnet_a  = aws_subnet.public_a.id
    public_subnet_b  = aws_subnet.public_b.id
  }
}
