# 03 - Lambda S3

This lab creates an event-driven S3 to Lambda flow with Terraform using Floci as a local AWS emulator.

The Terraform code was written manually to make sure I understand how S3 events, Lambda functions, IAM roles, Lambda permissions, and S3 bucket notifications connect to each other.

## Resources

- S3 bucket: `03-lambda-s3`
- HTTPS-only bucket policy for the S3 bucket
- IAM role: `lambda-role-03-lambda-s3`
- Custom IAM policy: `s3-access-03-lambda-s3`
- IAM policy attachment from the Lambda role to the S3 access policy
- Lambda function: `s3-processor-03-lambda-s3`
- Lambda deployment package created from `app/index.js`
- Lambda permission allowing S3 to invoke the Lambda function
- S3 bucket notification for object creation events under `input/`
- Terraform outputs for the S3 bucket, Lambda function, Lambda role, and IAM policy

## What I learned

- How to package Lambda code with the `archive` provider
- How to create a Lambda function with Terraform
- How to create a Lambda execution role
- How to use a trust policy with `lambda.amazonaws.com`
- How to allow Lambda to read from S3 `input/*`
- How to allow Lambda to write to S3 `output/*`
- How `aws_lambda_permission` allows S3 to invoke a Lambda function
- How `aws_s3_bucket_notification` connects S3 object-created events to Lambda
- How to scope S3 event notifications by prefix
- How to verify an end-to-end S3 to Lambda flow

## Event flow

```text
Upload file to S3 input/
-> S3 object-created event
-> S3 bucket notification
-> Lambda function invoke
-> Lambda reads the input object
-> Lambda writes a processed object to output/
```

## Permission paths

S3 invoking Lambda:

```text
S3 bucket -> aws_lambda_permission -> Lambda function
```

The Lambda permission allows the S3 service to invoke the Lambda function, but only from this specific bucket.

Lambda accessing S3:

```text
Lambda function -> Lambda execution role -> s3_access policy -> S3 input/output prefixes
```

The Lambda role can:

```text
s3:GetObject on input/*
s3:PutObject on output/*
```

This means Lambda can read uploaded files from `input/` and write processed files to `output/`.

## Test

Run from this project directory:

```sh
../../tools/tf.sh plan
../../tools/tf.sh apply
```

Upload a test file:

```sh
echo "hello lambda" > /tmp/hello.txt
aws s3 cp /tmp/hello.txt s3://03-lambda-s3/input/hello.txt
```

Check the processed output:

```sh
aws s3 ls s3://03-lambda-s3/output/
aws s3 cp s3://03-lambda-s3/output/hello.txt -
```

Expected output:

```text
Processed by Lambda:
hello lambda
```

Check the S3 notification configuration:

```sh
aws s3api get-bucket-notification-configuration \
  --bucket 03-lambda-s3
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
aws s3 rm s3://03-lambda-s3 --recursive
../../tools/tf.sh destroy
```

## Notes

This lab uses Floci, not real AWS.

The design still follows the real AWS pattern:

```text
S3 event source -> Lambda function -> IAM execution role -> S3 read/write permissions
```

The important distinction is:

```text
aws_lambda_permission controls who can invoke the Lambda function.
The Lambda execution role controls what the Lambda function can do after it starts running.
```
