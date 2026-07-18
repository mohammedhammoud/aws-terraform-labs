# 02 - IAM Basics

IAM users, groups, policies, and roles wired to one S3 bucket.

## Architecture

```mermaid
flowchart LR
    User[developer user] --> Group[developers group]
    Group --> Policy[s3_read_only policy]
    Policy --> S3[S3 read-only access]

    EC2[EC2 service] --> Assume[sts:AssumeRole]
    Assume --> Role[app_role]
    Role --> Policy
```

## Resources

- S3 bucket: `02-iam-basics`
- HTTPS-only bucket policy and public access block
- IAM user: `developer`
- IAM group: `developers`
- Custom read-only S3 policy
- IAM role: `app-role-02-iam-basics`
- Trust policy for EC2

## Permission paths

```text
developer user -> developers group -> s3_read_only policy -> S3 read-only access
EC2 service -> sts:AssumeRole -> app_role -> s3_read_only policy -> S3 read-only access
```

## What I learned

- How a user inherits permissions through a group
- How trust policies differ from permission policies
- How one policy can be reused for both humans and workloads
- Why `sts:AssumeRole` gives workloads temporary credentials

## Run

```sh
../../tools/tf.sh plan
../../tools/tf.sh apply
../../tools/tf.sh destroy
```
