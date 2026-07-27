locals {
  name_prefix = "${data.aws_caller_identity.current.account_id}-${var.project_name}"
}
