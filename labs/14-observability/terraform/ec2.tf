resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  user_data_replace_on_change = true
  monitoring                  = true

  user_data = templatefile("${path.module}/scripts/ec2-user-data.sh", {
    index_html_base64 = base64encode(
      file("${path.module}/templates/index.html")
    )

    server_py_base64 = base64encode(
      file("${path.module}/templates/server.py")
    )

    systemd_service_base64 = base64encode(
      file("${path.module}/templates/observability-app.service")
    )

    cloudwatch_config_base64 = base64encode(
      templatefile("${path.module}/templates/cloudwatch-agent.json.tftpl", {
        application_log_group = aws_cloudwatch_log_group.application.name
        user_data_log_group   = aws_cloudwatch_log_group.user_data.name
      })
    )
  })

  tags = {
    Name = "${var.project_name}-web"
  }
}
