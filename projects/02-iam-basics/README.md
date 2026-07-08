# 02 - IAM Basics

This lab creates basic IAM identities and permissions with Terraform using Floci as a local AWS emulator.

The Terraform code was written manually to make sure I understand the difference between IAM users, groups, policies, roles, trust policies, and policy attachments.

## Resources

- S3 bucket: `02-iam-basics`
- HTTPS-only bucket policy for the S3 bucket
- IAM user: `developer`
- IAM group: `developers`
- User group membership from `developer` to `developers`
- Custom IAM policy: `s3-read-only-02-iam-basics`
- Group policy attachment from `developers` to the S3 read-only policy
- IAM role: `app-role-02-iam-basics`
- Trust policy allowing the EC2 service to assume the role
- Role policy attachment from `app-role-02-iam-basics` to the S3 read-only policy
- Terraform outputs for the IAM identities

## What I learned

- How to create IAM users and groups with Terraform
- How to add a user to a group
- How to create a custom IAM policy with `jsonencode`
- How to attach a policy to an IAM group
- How IAM users can receive permissions through groups
- How to create an IAM role for a workload
- How trust policies control who can assume a role
- How `sts:AssumeRole` is used to get temporary credentials for a role
- How to attach the same permissions policy to both a group and a role

## Permission paths

Human access path:

```text
developer user -> developers group -> s3_read_only policy -> S3 read-only access
```

Workload access path:

```text
EC2 service -> sts:AssumeRole -> app_role -> s3_read_only policy -> S3 read-only access
```

## Commands

Run from the repository root:

```sh
./tools/tf.sh 02-iam-basics plan
./tools/tf.sh 02-iam-basics apply
./tools/tf.sh 02-iam-basics destroy
```