data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

resource "aws_launch_template" "ecs" {
  name_prefix = "${local.name_prefix}-lt-"

  instance_type = var.ec2_instance_type
  image_id      = data.aws_ssm_parameter.ecs_optimized_ami.value

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  vpc_security_group_ids = [aws_security_group.ecs_instance.id]
  user_data = base64encode(templatefile(
    "${path.module}/scripts/ecs-user-data.sh",
    {
      cluster_name = aws_ecs_cluster.main.name
    }
  ))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name_prefix}-ecs-instance"
    }
  }

  tags = {
    Name = "${local.name_prefix}-launch-template"
  }
}
