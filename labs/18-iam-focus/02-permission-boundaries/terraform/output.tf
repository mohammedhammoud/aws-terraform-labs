output "role_1_arn" {
  value = aws_iam_role.role_1.arn
}

output "role_2_boundary_arn" {
  value = aws_iam_policy.role_boundary_2.arn
}
