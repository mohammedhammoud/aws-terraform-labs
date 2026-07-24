output "iam_identities" {
  value = {
    group_arn = aws_iam_group.developers.arn
    user_arn  = aws_iam_user.developer.arn
    role_arn  = aws_iam_role.app_role.arn
  }
}
