# Bootstrap Terraform

This root owns shared GitHub-to-AWS access and shared Terraform state protections.

## Owns

- state bucket `455394301478-terraform-state-s3`
- bucket versioning, encryption, public access block, HTTPS-only policy
- GitHub OIDC provider
- global PR plan role `github-actions-terraform-plan`
- workload-specific GitHub Actions apply identities
  - role
  - OIDC trust policy
  - Terraform apply policy
  - attachment between the role and apply policy

Current workload apply role naming:

- `github-actions-ecs-fargate-<env>-terraform`

Supported environments:

- `dev`
- `stage`
- `prod`

## Does not own

- ECS Fargate workload resources
- workload-specific deploy policies
- deploy-policy attachments managed by workload roots

## Commands

From `infra/bootstrap/terraform`:

```sh
terraform init -reconfigure -input=false
terraform validate
terraform plan
terraform apply
terraform output -raw github_actions_plan_role_arn
terraform output -json ecs_fargate_github_actions_apply_role_arns
```

## Outputs

Repository variable:

```sh
terraform output -raw github_actions_plan_role_arn
```

GitHub Environment variables for ECS Fargate:

```sh
terraform output -json ecs_fargate_github_actions_apply_role_arns
```

Set `AWS_ECS_FARGATE_TERRAFORM_APPLY_ROLE_ARN` per environment from that output.
