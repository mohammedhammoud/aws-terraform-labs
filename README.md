# AWS Terraform Labs

AWS and Terraform learning repo with:

- `labs/` for smaller focused exercises
- `infra/` for larger AWS-backed stacks

## Repo structure

```text
labs/
  <lab-name>/
    README.md
    terraform/
infra/
  bootstrap/
    terraform/
  ecs-fargate/
    README.md
    terraform/
tools/
  tf.sh
```

## Labs

Use `labs/` for smaller experiments and concept practice.

Typical lab flow:

```sh
cd labs/<lab-name>
../../tools/tf.sh init
../../tools/tf.sh plan
```

Many labs were designed for local Floci.

## Infrastructure

Use `infra/` for the current shared AWS setup.

Current Terraform roots:

- `infra/bootstrap/terraform`
  - state bucket protections
  - GitHub OIDC provider
  - global PR plan role `github-actions-terraform-plan`
  - workload-specific apply identities
- `infra/ecs-fargate/terraform`
  - ECS Fargate workload resources
  - workload-specific deploy policy and attachment

Supported environments:

- `dev`
- `stage`
- `prod`

GitHub Actions variables:

- repository variable: `AWS_TERRAFORM_PLAN_ROLE_ARN`
- environment variable: `AWS_ECS_FARGATE_TERRAFORM_APPLY_ROLE_ARN`

ECS helper:

```sh
cd infra/ecs-fargate
../../tools/tf.sh --env dev fmt
../../tools/tf.sh --env dev validate
../../tools/tf.sh --env dev plan -var frontend_image_tag=bootstrap -var backend_image_tag=bootstrap
```

Bootstrap runs directly from `infra/bootstrap/terraform` with `terraform`.

## Infra docs

- [Bootstrap](infra/bootstrap/terraform/README.md)
- [ECS Fargate](infra/ecs-fargate/README.md)
