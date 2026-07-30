# Bootstrap Terraform

This root owns only:

- the existing Terraform state bucket `455394301478-terraform-state-s3`
- bucket versioning
- bucket encryption
- public access block
- the HTTPS-only bucket policy
- the GitHub OIDC provider
- the global GitHub Actions pull-request plan role, policy, and attachment

Bootstrap changes are applied locally.

## Commands

From `infra/bootstrap/terraform`:

```sh
terraform init -reconfigure -input=false
terraform validate
terraform plan
terraform apply
```

Only run `terraform apply` after reviewing a plan with no unexpected changes or destroys.

## Outputs

Use this output for the repository variable `AWS_TERRAFORM_PLAN_ROLE_ARN`:

```sh
terraform output -raw github_actions_plan_role_arn
```
