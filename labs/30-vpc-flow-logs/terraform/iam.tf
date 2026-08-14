data "aws_iam_policy_document" "flow_logs_trust_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flow_log" {
  name               = "${var.project_name}-flow-logs-access"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_trust_policy.json
}

data "aws_iam_policy_document" "flow_log_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "flow_log_permissions" {
  name   = "${var.project_name}-flow-logs-permissions"
  policy = data.aws_iam_policy_document.flow_log_permissions.json
}

resource "aws_iam_role_policy_attachment" "flow_log_permissions" {
  role       = aws_iam_role.flow_log.name
  policy_arn = aws_iam_policy.flow_log_permissions.arn
}
