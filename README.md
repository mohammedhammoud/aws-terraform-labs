# AWS Floci Lab

Hands-on AWS learning lab repo for building and testing small Terraform examples without using real AWS.

This repo uses Terraform and Floci.
It is a learning-in-public lab, not production-ready infrastructure.
Do not treat it as proof of exact real AWS behavior, especially for edge cases.

Floci is the local AWS emulator.
`direnv` loads Floci environment variables when you enter this repo.

## Start Floci

```sh
floci start
```

## Load Floci env vars

`direnv` should load `.envrc` automatically when you enter the repo.

If needed:

```sh
direnv allow
```

## Verify AWS CLI points to Floci

```sh
aws sts get-caller-identity
echo $AWS_ENDPOINT_URL
```

Expected local values:
- Account: `000000000000`
- Arn: `arn:aws:iam::000000000000:root`
- Endpoint: `http://localhost.floci.io:4566`

## Labs

- `01-s3-basics` - S3 bucket, access logging, HTTPS-only bucket policy
- `02-iam-basics` - IAM users, groups, policies, roles, trust policies
- `03-lambda-s3` - S3 event notification invoking Lambda
- `04-ec2-basics` - EC2 instance role, instance profile, user data, S3 access
- `05-vpc-basics` - VPC, public subnet, route table, internet gateway, security group, EC2
