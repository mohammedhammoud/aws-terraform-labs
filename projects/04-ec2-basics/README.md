# 04 - EC2 Basics

Basic EC2 + IAM + S3 lab for Floci.

This is a learning-in-public lab. It uses Floci to emulate AWS locally, so runtime behavior can differ from real AWS.

## Resources

- S3 bucket: `04-ec2-basics`
- HTTPS-only bucket policy and explicit S3 public access block
- IAM role: `ec2-role-04-ec2-basics`
- Custom IAM policy: `s3-access-04-ec2-basics`
- IAM policy attachment from the EC2 role to the S3 access policy
- IAM instance profile: `ec2-profile-04-ec2-basics`
- EC2 instance using the Floci Amazon Linux 2023 image
- External user data script loaded with `templatefile`
- Terraform outputs for the main resources

## Boot flow

```text
Terraform creates EC2 instance
-> Floci starts a Docker container for the instance
-> user_data script runs inside the container
-> script creates /tmp/ec2-test.txt
-> script installs AWS CLI
-> script uploads ec2-test.txt to S3
```

## Permission path

```text
EC2 instance -> IAM instance profile -> EC2 role -> s3_access policy -> S3 bucket
```

Allowed object access:

```text
s3:PutObject on 04-ec2-basics/*
```

## What I learned

- How to create an EC2 instance with Terraform
- How `user_data` bootstraps a workload at instance start
- How to keep bootstrap logic in a separate script with `templatefile`
- How an instance profile connects an IAM role to EC2
- How an EC2 workload can write to S3 without hardcoded credentials
- How to inspect a Floci EC2 instance through its backing Docker container

## Test

Run from this project directory:

```sh
../../tools/tf.sh plan
../../tools/tf.sh apply
```

Check that the EC2 container is running:

```sh
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
```

Check the user data log inside the container:

```sh
docker exec -it <container-name> bash
cat /tmp/user-data.log
cat /tmp/ec2-test.txt
aws --version
```

Check that the EC2 instance uploaded the file to S3:

```sh
aws s3 ls s3://04-ec2-basics/
aws s3 cp s3://04-ec2-basics/ec2-test.txt -
```

Expected output:

```text
hello from ec2
```

## Commands

Run from this project directory:

```sh
../../tools/tf.sh plan
../../tools/tf.sh apply
../../tools/tf.sh destroy
```

If destroy fails because the bucket is not empty:

```sh
aws s3 rm s3://04-ec2-basics --recursive
../../tools/tf.sh destroy
```

## Floci note

Floci runs EC2 instances as local Docker containers. The IAM role still models the real AWS permission path, but runtime details can differ from AWS.

Important distinction:

```text
The IAM role controls what the EC2 workload can do.
The instance profile connects that IAM role to the EC2 instance.
The user_data script bootstraps the workload when the instance starts.
```
