data "aws_iam_policy_document" "cloudfront_s3" {
  for_each = merge(
    local.ecs_ec2_ci_instances,
    local.ecs_fargate_e2e_ci_instances,
  )

  statement {
    sid = "ManageFrontendBucket"

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucketTagging",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketOwnershipControls",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketTagging",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-${each.value.name_prefix}-frontend",
    ]
  }

  statement {
    sid = "ManageFrontendBucketObjects"

    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
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
      "cloudfront:CreateOriginAccessControl",
      "cloudfront:DeleteDistribution",
      "cloudfront:DeleteOriginAccessControl",
      "cloudfront:GetCachePolicy",
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:GetOriginAccessControl",
      "cloudfront:GetOriginAccessControlConfig",
      "cloudfront:GetOriginRequestPolicy",
      "cloudfront:ListCachePolicies",
      "cloudfront:ListOriginAccessControls",
      "cloudfront:ListOriginRequestPolicies",
      "cloudfront:ListTagsForResource",
      "cloudfront:TagResource",
      "cloudfront:UntagResource",
      "cloudfront:UpdateDistribution",
      "cloudfront:UpdateOriginAccessControl",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudfront_s3" {
  for_each = merge(
    local.ecs_ec2_ci_instances,
    local.ecs_fargate_e2e_ci_instances,
  )

  name   = "${each.value.apply_role_name}-cf-s3"
  policy = data.aws_iam_policy_document.cloudfront_s3[each.key].json
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudfront_s3" {
  for_each = local.ecs_ec2_ci_instances

  role       = aws_iam_role.ecs_ec2_github_actions_apply[each.key].name
  policy_arn = aws_iam_policy.cloudfront_s3[each.key].arn
}

resource "aws_iam_role_policy_attachment" "ecs_fargate_e2e_cloudfront_s3" {
  for_each = local.ecs_fargate_e2e_ci_instances

  role       = aws_iam_role.ecs_fargate_e2e_github_actions_apply[each.key].name
  policy_arn = aws_iam_policy.cloudfront_s3[each.key].arn
}
