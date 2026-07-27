# Terraform state bootstrap with Terraform

Bootstrap Terraform for a remote S3 state bucket.

## Resources

- S3 bucket for Terraform state
- Block public access
- HTTPS-only bucket policy
- Bucket versioning
- S3 server-side encryption
- IAM policy for GitHub Actions apply role
- IAM policy for GitHub Actions plan role

## Access

Apply role:

```text
s3:GetObject
s3:PutObject
s3:DeleteObject
s3:ListBucket
```

Plan role:

```text
s3:GetObject
s3:ListBucket
```

## Output

- `bucket_name`

## Run

This expects the GitHub OIDC bootstrap roles to already exist.

From `infra/bootstrap/terraform-state`:

```sh
../../../tools/tf.sh init
../../../tools/tf.sh plan
../../../tools/tf.sh apply
```
