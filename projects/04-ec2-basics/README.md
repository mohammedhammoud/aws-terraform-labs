# 04 - EC2 Basics

This lab creates a basic EC2 instance with Terraform using Floci as a local AWS emulator.

The Terraform code was written manually to make sure I understand how EC2 instances, AMIs, IAM roles, instance profiles, user data, and S3 permissions connect to each other.

## Resources

- S3 bucket: `04-ec2-basics`
- HTTPS-only bucket policy for the S3 bucket
- IAM role: `ec2-role-04-ec2-basics`
- Custom IAM policy: `s3-access-04-ec2-basics`
- IAM policy attachment from the EC2 role to the S3 access policy
- IAM instance profile: `ec2-profile-04-ec2-basics`
- EC2 instance using the Floci Amazon Linux 2023 image
- External user data script loaded with `templatefile`
- Terraform outputs for the S3 bucket, EC2 instance, IAM role, instance profile, and IAM policy

## What I learned

- How to create an EC2 instance with Terraform
- What an AMI is
- How to configure an instance type
- How to disable public IP assignment explicitly
- How to use `user_data` to run bootstrap commands when an instance starts
- How to keep user data in a separate script file
- How to use `templatefile` to pass Terraform values into a script
- How to create an IAM role for EC2
- How to use a trust policy with `ec2.amazonaws.com`
- How EC2 uses an instance profile to receive an IAM role
- How to attach S3 permissions to an EC2 role
- How an EC2 instance can write to S3 using its role permissions
- How to verify a Floci EC2 instance through its Docker container

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

EC2 accessing S3:

```text
EC2 instance -> IAM instance profile -> EC2 role -> s3_access policy -> S3 bucket
```

The EC2 role can:

```text
s3:PutObject on 04-ec2-basics/*
```

This means the EC2 instance can upload objects to the lab S3 bucket.

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

Example container name:

```text
floci-ec2-i-ba891a9fd433a2053
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

## Notes

This lab uses Floci, not real AWS.

Floci runs EC2 instances as local Docker containers. The design still follows the real AWS pattern:

```text
EC2 instance -> IAM instance profile -> IAM role -> S3 write permissions
```

The important distinction is:

```text
The IAM role controls what the EC2 workload can do.
The instance profile connects the IAM role to the EC2 instance.
The user_data script runs when the instance starts and bootstraps the workload.
```
