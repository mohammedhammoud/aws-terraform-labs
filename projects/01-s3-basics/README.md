# 01 - S3 Basics

This lab creates a private S3 bucket with Terraform using Floci as a local AWS emulator.

The Terraform code was written manually to make sure I understand what each resource does and how the resources connect to each other.

## Resources

- Main S3 bucket: `01-s3-basics`
- Separate log bucket: `01-s3-basics-logs`
- Server access logging from the main bucket to the log bucket
- HTTPS-only bucket policy on both buckets using a local value and `for_each`
- Terraform outputs for the main bucket

## What I learned

- How to create S3 buckets with Terraform
- How Terraform references resources
- How to use bucket policies with `jsonencode`
- How to use `for_each` to apply the same pattern to multiple resources
- Why the log bucket should not log to itself
- Why public S3 access should usually be avoided

## Commands

Run from this project directory:

```sh
../../tools/tf.sh plan
../../tools/tf.sh apply
../../tools/tf.sh destroy
```