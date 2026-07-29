data "aws_iam_policy_document" "github" {
  for_each = local.github_roles

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = each.value
    }
  }
}

resource "aws_iam_role" "github_actions" {
  for_each           = local.github_roles
  name               = "${local.name_prefix}-github-actions-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.github[each.key].json
}

resource "aws_iam_role_policy_attachment" "github_actions_plan_readonly" {
  role       = aws_iam_role.github_actions["plan"].name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "apply" {
  statement {
    actions = ["iam:GetRole"]

    resources = [
      aws_iam_role.github_actions["apply"].arn,
    ]
  }
}

resource "aws_iam_role_policy" "apply" {
  name   = "${local.name_prefix}-github-actions-apply"
  role   = aws_iam_role.github_actions["apply"].name
  policy = data.aws_iam_policy_document.apply.json
}
