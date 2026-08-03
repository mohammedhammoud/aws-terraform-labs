data "aws_iam_policy_document" "ecs_ec2_cf_s3" {
  for_each = local.ecs_ec2_ci_instances

  statement {
    sid = "ManageFrontendBucket"

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:DeleteBucketPolicy",
      "s3:GetBucketTagging",
      "s3:PutBucketTagging",
      "s3:DeleteBucketTagging",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-${each.value.name_prefix}-frontend",
    ]
  }

  statement {
    sid = "ManageFrontendBucketObjects"

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-${each.value.name_prefix}-frontend/*",
    ]
  }

  statement {
    sid = "ManageCloudFront"

    actions = [
      "cloudfront:CreateDistribution",
      "cloudfront:DeleteDistribution",
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListTagsForResource",
      "cloudfront:TagResource",
      "cloudfront:UntagResource",
      "cloudfront:UpdateDistribution",
      "cloudfront:CreateOriginAccessControl",
      "cloudfront:DeleteOriginAccessControl",
      "cloudfront:GetOriginAccessControl",
      "cloudfront:GetOriginAccessControlConfig",
      "cloudfront:ListOriginAccessControls",
      "cloudfront:UpdateOriginAccessControl",
      "cloudfront:GetCachePolicy",
      "cloudfront:ListCachePolicies",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_ec2_cf_s3" {
  for_each = local.ecs_ec2_ci_instances

  name   = "${each.value.apply_role_name}-cf-s3"
  policy = data.aws_iam_policy_document.ecs_ec2_cf_s3[each.key].json
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cf_s3" {
  for_each = local.ecs_ec2_ci_instances

  role       = aws_iam_role.ecs_ec2_github_actions_apply[each.key].name
  policy_arn = aws_iam_policy.ecs_ec2_cf_s3[each.key].arn
}
