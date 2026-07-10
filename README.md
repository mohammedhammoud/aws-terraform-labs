# AWS Floci Lab

Learning-in-public repo for small AWS + Terraform labs, run locally with Floci.

## Disclaimer

- Floci emulates AWS locally.
- Behavior can differ from real AWS.
- This repo is for learning and experimentation, not production.

## Repo structure

```text
projects/
  01-s3-basics/
  02-iam-basics/
  03-lambda-s3/
  04-ec2-basics/
  05-vpc-basics/
  06-alb-ec2-basics/
tools/
  tf.sh
```

Each lab has:
- a `README.md` with context, test steps, and Floci caveats
- a `terraform/` directory with the actual Terraform config

## Prerequisites

- `floci`
- `terraform`
- `direnv`
- `awscli`
- `python3`
- `node`

## Start Floci

```sh
floci start
direnv allow
aws sts get-caller-identity
```

Expected local values:
- Account: `000000000000`
- Arn: `arn:aws:iam::000000000000:root`
- Endpoint: `http://localhost.floci.io:4566`

## Run a lab

Example:

```sh
cd projects/01-s3-basics
../../tools/tf.sh init
../../tools/tf.sh plan
../../tools/tf.sh apply
../../tools/tf.sh destroy
```

`tools/tf.sh` expects to be run from a lab directory or its `terraform/` subdirectory.

## Labs

- `01-s3-basics` — private S3 bucket, access logging, HTTPS-only bucket policies
- `02-iam-basics` — IAM users, groups, policies, roles, trust policies
- `03-lambda-s3` — S3 event notification invoking Lambda
- `04-ec2-basics` — EC2 instance role, instance profile, user data, S3 access
- `05-vpc-basics` — VPC, public subnet, route table, internet gateway, security group, EC2
- `06-alb-ec2-basics` — ALB, target group, listener, security groups, EC2 backend

## Security and cost

These labs are intended for local Floci usage.

Do not point them at real AWS without reviewing:
- resources created
- IAM permissions
- networking exposure
- possible cost impact

## CI

GitHub Actions checks:
- `terraform fmt -check -recursive`
- `terraform init -backend=false`
- `terraform validate`

Each Terraform lab is validated separately without real AWS credentials.
