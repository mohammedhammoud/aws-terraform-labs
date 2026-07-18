# AWS Terraform Labs

Hands-on AWS labs built with Terraform. Each lab focuses on one concept—like S3, IAM, Lambda, EC2, VPC, ECS, RDS, or EventBridge—so you can learn AWS, Infrastructure as Code, and DevOps by building small examples.

Most labs are designed for local Floci. A few were only verified in AWS where local support was missing.

## Topics covered

AWS, Terraform, Infrastructure as Code, DevOps, cloud engineering, S3, IAM, Lambda, EC2, VPC, ALB, ECS, Step Functions, CloudFront, EventBridge, RDS, CloudWatch, GitHub Actions OIDC, and SQS.

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

## Run a Terraform lab

```sh
cd projects/01-s3-basics
../../tools/tf.sh init
../../tools/tf.sh plan
../../tools/tf.sh apply
../../tools/tf.sh destroy
```

`tools/tf.sh` expects to run from a lab directory or its `terraform/` subdirectory.

## Labs

| Lab | AWS service(s) | Main concepts | Link |
|---|---|---|---|
| 01 | S3 | buckets, access logging, bucket policies, public access block | [01-s3-basics](projects/01-s3-basics) |
| 02 | IAM, S3 | users, groups, policies, roles, trust policies | [02-iam-basics](projects/02-iam-basics) |
| 03 | Lambda, S3 | event notifications, Lambda permissions, object processing | [03-lambda-s3](projects/03-lambda-s3) |
| 04 | EC2, IAM, S3 | instance profiles, user data, S3 access from EC2 | [04-ec2-basics](projects/04-ec2-basics) |
| 05 | VPC, EC2 | public subnet, route tables, internet gateway, security groups | [05-vpc-basics](projects/05-vpc-basics) |
| 06 | ALB, EC2, VPC | listeners, target groups, security group references | [06-alb-ec2-basics](projects/06-alb-ec2-basics) |
| 07 | ALB, EC2 Auto Scaling, VPC | launch templates, Auto Scaling Group, health checks | [07-alb-autoscaling](projects/07-alb-autoscaling) |
| 08 | ECS, Fargate, ALB, VPC | `awsvpc`, IP targets, ECS service networking | [08-ecs-fargate-alb](projects/08-ecs-fargate-alb) |
| 09 | ECS, EC2, ALB, Auto Scaling | ECS on EC2, cluster capacity, `awsvpc` tasks | [09-ecs-ec2-alb](projects/09-ecs-ec2-alb) |
| 10 | Step Functions, Lambda | workflow orchestration, choice states, Lambda tasks | [10-step-functions](projects/10-step-functions) |
| 11 | CloudFront, S3 | Origin Access Control, private S3 origins, bucket policy | [11-cloudfront-s3-oac](projects/11-cloudfront-s3-oac) |
| 12 | EventBridge, Lambda | custom event buses, rules, fan-out to Lambda | [12-eventbridge](projects/12-eventbridge) |
| 13 | RDS, EC2, VPC | private PostgreSQL, DB subnet groups, security groups | [13-rds-private](projects/13-rds-private) |
| 14 | CloudWatch, EC2, SNS | logs, metrics, dashboards, alarms, notifications | [14-observability](projects/14-observability) |
| 15 | IAM, STS, GitHub Actions | GitHub OIDC, trust policies, temporary credentials | [15-github-oidc](projects/15-github-oidc) |
| 16 | ECS, EC2, ALB, CodeDeploy | blue/green deployments, target groups, traffic shifting | [16-ecs-blue-green](projects/16-ecs-blue-green) |
| 17 | SQS, Lambda | event source mapping, visibility timeout, async processing | [17-sqs-basics](projects/17-sqs-basics) |

## Notes

- Local Floci behavior can differ from AWS.
- Review IAM, networking, and cost before pointing any lab at real AWS.
- CI only runs static Terraform checks. It does not prove end-to-end runtime behavior.
