# ECS Fargate Terraform

Terraform for an ECS Fargate workload behind an ALB with private PostgreSQL on RDS.

## Ownership

`infra/ecs-fargate/terraform` owns:

- VPC, subnets, routing, NAT, security groups
- ALB, listeners, target groups
- ECS cluster, task definitions, services
- ECR repositories
- CloudWatch log groups
- RDS and related secrets usage
- workload IAM roles
- deploy policy `ecs-fargate-<env>-github-actions-deploy`
- attachment of that deploy policy to the bootstrap-owned apply role

`infra/bootstrap/terraform` owns:

- GitHub OIDC provider
- global PR plan role
- apply role `github-actions-ecs-fargate-<env>-terraform`
- apply policy and its attachment

## Environments

Supported environments:

- `dev`
- `stage`
- `prod`

Terraform state key pattern:

- `aws-terraform-labs/ecs-fargate/<env>/terraform.tfstate`

GitHub Actions environment variable required per environment:

- `AWS_ECS_FARGATE_TERRAFORM_APPLY_ROLE_ARN=arn:aws:iam::455394301478:role/github-actions-ecs-fargate-<env>-terraform`

## Wrapper

Run from `infra/ecs-fargate`:

```sh
../../scripts/tf-ecs.sh dev fmt
../../scripts/tf-ecs.sh dev validate
../../scripts/tf-ecs.sh dev plan -var frontend_image_tag=bootstrap -var backend_image_tag=bootstrap
../../scripts/tf-ecs.sh dev apply -var frontend_image_tag=bootstrap -var backend_image_tag=bootstrap
../../scripts/tf-ecs.sh dev destroy -var frontend_image_tag=bootstrap -var backend_image_tag=bootstrap
```

Behavior:

- `fmt`: no init, no environment var injection
- `validate`: runs init, no `-var`
- `plan|apply|destroy|refresh`: runs init and adds `-var="environment=<env>"`

## First run

Create ECR first:

```sh
../../scripts/tf-ecs.sh dev apply \
  -target=aws_ecr_repository.frontend \
  -target=aws_ecr_lifecycle_policy.frontend \
  -target=aws_ecr_repository.backend \
  -target=aws_ecr_lifecycle_policy.backend \
  -var frontend_image_tag=bootstrap \
  -var backend_image_tag=bootstrap
```

Then push images and apply the rest of the stack.

## Verify

```sh
curl "http://$(terraform -chdir=terraform output -raw alb_dns_name)/api/todos"
aws logs tail "/ecs/ecs-fargate-dev/backend" --region eu-north-1
```

## Notes

- DB app values stay workload-specific: `db_name=tododb`, `db_username=todouser`
- RDS is private and currently single-AZ
- ALB is HTTP only
- NAT gateways and RDS cost money while running
