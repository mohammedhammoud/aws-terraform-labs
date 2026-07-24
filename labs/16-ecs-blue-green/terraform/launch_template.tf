resource "aws_launch_template" "ecs" {
  name_prefix = "${var.project_name}-lt-"

  instance_type = var.ec2_instance_type
  image_id      = var.ec2_ami

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  vpc_security_group_ids = [aws_security_group.ec2.id]
  user_data = base64encode(templatefile(
    "${path.module}/scripts/ecs-user-data.sh",
    {
      cluster_name = aws_ecs_cluster.lab.name
    }
  ))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-ecs-instance"
    }
  }
}
