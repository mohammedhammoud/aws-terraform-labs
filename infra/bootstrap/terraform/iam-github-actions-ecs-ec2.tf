data "aws_iam_policy_document" "ecs_ec2_github_actions_apply" {
  for_each = local.ecs_ec2_ci_instances

  source_policy_documents = [
    data.aws_iam_policy_document.ecs_base[each.key].json,
  ]

  statement {
    sid = "ReadEcsOptimizedAmi"

    actions = ["ssm:GetParameter"]
    resources = [
      "arn:aws:ssm:${var.region}::parameter/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id",
    ]
  }

  statement {
    sid = "AutoScaling"

    actions   = ["autoscaling:*"]
    resources = ["*"]
  }

  statement {
    sid = "ManageInstanceProfiles"

    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:UntagInstanceProfile",
    ]

    resources = [each.value.instance_profile_arn]
  }

  statement {
    sid = "ListInstanceProfilesForRole"

    actions   = ["iam:ListInstanceProfilesForRole"]
    resources = [each.value.ec2_instance_role_arn]
  }

  statement {
    sid = "PassEc2RoleToEc2"

    actions   = ["iam:PassRole"]
    resources = [each.value.ec2_instance_role_arn]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }

  statement {
    sid = "CreateAutoScalingServiceLinkedRole"

    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["autoscaling.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_ec2_github_actions_apply" {
  for_each = local.ecs_ec2_ci_instances

  name               = each.value.apply_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_github_actions_apply_assume_role[each.key].json
}

resource "aws_iam_policy" "ecs_ec2_github_actions_apply" {
  for_each = local.ecs_ec2_ci_instances

  name   = each.value.apply_policy_name
  policy = data.aws_iam_policy_document.ecs_ec2_github_actions_apply[each.key].json
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_github_actions_apply" {
  for_each = local.ecs_ec2_ci_instances

  role       = aws_iam_role.ecs_ec2_github_actions_apply[each.key].name
  policy_arn = aws_iam_policy.ecs_ec2_github_actions_apply[each.key].arn
}
