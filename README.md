# AWS Floci Lab

Small AWS + Terraform labs. Mostly built for local Floci. A few were only verified in AWS where local support was missing.

## Repo structure

```text
projects/
  <lab-name>/
    README.md
    terraform/
tools/
  tf.sh
```

Each lab has:
- a short `README.md`
- Terraform in `terraform/`

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

```sh
cd projects/01-s3-basics
../../tools/tf.sh init
../../tools/tf.sh plan
../../tools/tf.sh apply
../../tools/tf.sh destroy
```

`tools/tf.sh` expects to run from a lab directory or its `terraform/` subdirectory.

## Labs

- `01-s3-basics` — private S3 bucket, access logging, HTTPS-only bucket policies
- `02-iam-basics` — IAM users, groups, policies, roles, trust policies
- `03-lambda-s3` — S3 event notification invoking Lambda
- `04-ec2-basics` — EC2 role, instance profile, user data, S3 access
- `05-vpc-basics` — VPC, public subnet, route table, internet gateway, security group, EC2
- `06-alb-ec2-basics` — ALB, target group, listener, security groups, EC2 backend
- `07-alb-autoscaling` — ALB, launch template, Auto Scaling Group, EC2 backend
- `08-ecs-fargate-alb` — ECS cluster, Fargate service, task definition, ALB
- `09-ecs-ec2-alb` — ECS cluster, EC2 capacity, task definition, service, ALB
- `10-step-functions` — Step Functions state machine with two Lambda steps
- `11-cloudfront-s3-oac` — CloudFront, private S3 origin, OAC, bucket policy
- `12-eventbridge` — custom event bus, rule, Lambda targets
- `13-rds-private` — public EC2 talking to private PostgreSQL RDS
- `14-observability` — EC2 metrics, logs, dashboard, alarm, SNS notifications
- `15-github-oidc` — GitHub Actions OIDC to AWS
- `16-ecs-blue-green` — ECS on EC2 with CodeDeploy blue/green
- `17-sqs-basics` — SQS queue, Lambda consumer, event source mapping

## Notes

- Local Floci behavior can differ from AWS.
- Review IAM, networking, and cost before pointing any lab at real AWS.
- CI only runs static Terraform checks. It does not prove end-to-end runtime behavior.
