resource "aws_launch_template" "web" {
  name_prefix = "07-alb-autoscaling-"

  instance_type = var.ec2_instance_type
  image_id      = var.ec2_ami

  vpc_security_group_ids = [aws_security_group.ec2.id]
  user_data              = base64encode(file("${path.module}/scripts/user-data.sh"))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "07-alb-autoscaling-lt"
    }
  }
}
