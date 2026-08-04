# AWS Terraform Labs

Collection of AWS and Terraform labs.

- `labs/` for smaller focused exercises
- `infra/` for larger end-to-end AWS stacks

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
  ecs-ec2/
    README.md
    terraform/
tools/
  tf.sh
```

## Labs

Use `labs/` for smaller experiments and practice.

Typical lab flow:

```sh
cd labs/<lab-name>
../../tools/tf.sh init
../../tools/tf.sh plan
```

Many labs were designed for local Floci.

## Infrastructure

Use `infra/` for the larger AWS setups in the repo.

Current Terraform roots:

- `infra/bootstrap/terraform`
  - state bucket protections
  - GitHub OIDC provider
  - global PR plan role `github-actions-terraform-plan`
  - environment-specific apply roles for the infra stacks
- `infra/ecs-fargate/terraform`
  - ECS Fargate workload resources
  - workload-specific deploy policy attachment for the apply role
- `infra/ecs-ec2/terraform`
  - ECS on EC2 workload resources
  - frontend S3 and CloudFront resources
  - workload-specific deploy policy attachment for the apply role

Terraform variables and bootstrap IAM are set up for:

- `dev`
- `stage`
- `prod`

The current GitHub Actions workflow inputs and PR matrices only enable:

- `dev`

GitHub Actions variables:

- repository variable: `TERRAFORM_STATE_BUCKET`
- repository variable: `AWS_TERRAFORM_PLAN_ROLE_ARN`
- environment variable: `AWS_ECS_FARGATE_TERRAFORM_APPLY_ROLE_ARN`
- environment variable: `AWS_ECS_EC2_TERRAFORM_APPLY_ROLE_ARN`

Terraform helper:

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
- [ECS EC2](infra/ecs-ec2/README.md)
