# VPC Endpoints

Terraform lab for testing private access to Amazon S3 through an S3 Gateway VPC Endpoint.

The lab creates:

- a VPC
- a private subnet
- a private route table
- a private EC2 instance with:
  - no public IP
  - no NAT Gateway
  - no Internet Gateway
- an S3 bucket
- an S3 Gateway VPC Endpoint
- an IAM role attached to the EC2 instance

## Goal

The goal is to prove that a private EC2 instance can communicate with S3 without using the public internet.

Normally, a private EC2 instance that needs outbound internet access would use:

```text
EC2
  ↓
private route table
  ↓
NAT Gateway
  ↓
Internet Gateway
  ↓
destination
```

In this lab there is no NAT Gateway or Internet Gateway.

Instead, S3 traffic uses:

```text
EC2
  ↓
private subnet
  ↓
private route table
  ↓
S3 Gateway VPC Endpoint
  ↓
S3
```

The S3 Gateway Endpoint is associated with the private route table.

AWS adds a route for the S3 service prefix list that points to the VPC Endpoint.

This allows resources using that route table to reach S3 without needing an internet route.

## IAM

The EC2 instance uses an IAM instance profile.

The role has:

- a trust policy allowing the EC2 service to assume the role
- permissions for:
  - `s3:ListBucket`
  - `s3:GetObject`
  - `s3:PutObject`

IAM and networking solve different problems:

```text
VPC Endpoint / routing
→ Can the EC2 instance reach S3?

IAM
→ Is the EC2 instance allowed to perform the requested S3 operation?
```

Both must allow the request.

## Test

Terraform creates the following S3 object:

```text
test.txt
```

with the content:

```text
hello from s3
```

When the EC2 instance starts, its user data:

1. downloads `test.txt` from S3
2. reads the contents
3. creates `result.txt`
4. uploads `result.txt` back to S3

The EC2 instance runs:

```bash
aws s3 cp "s3://<bucket>/test.txt" /tmp/test.txt

CONTENT=$(cat /tmp/test.txt)

echo "success: read '$CONTENT' via vpc endpoint" > /tmp/result.txt

aws s3 cp /tmp/result.txt "s3://<bucket>/result.txt"
```

The result can then be verified locally:

```bash
aws s3 cp "s3://$(terraform output -raw s3_bucket)/result.txt" -
```

Result:

```text
success: read 'hello from s3' via vpc endpoint
```

This proves that the private EC2 instance successfully read from and wrote to S3 through the S3 Gateway VPC Endpoint without a NAT Gateway, Internet Gateway, or public IP.
