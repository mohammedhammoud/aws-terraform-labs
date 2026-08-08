# IAM Policy Evaluation Mix

Terraform lab for testing how multiple IAM policy types interact.

The lab creates:

- an IAM role
- an S3 bucket with a test object
- an identity policy
- a permissions boundary
- an S3 bucket policy

A session policy is also passed when assuming the role with STS.

## Identity policy

The role allows:

- `s3:GetObject`
- `s3:PutObject`

## Permissions boundary

The boundary also allows:

- `s3:GetObject`
- `s3:PutObject`

This means the boundary does not further restrict the role in the final scenario.

## Session policy

The role is assumed with a session policy that only allows:

- `s3:GetObject`

The session policy is not created by Terraform. It is passed to STS when the role is assumed and only applies to that temporary session.

### Assume the role

    CREDS=$(aws sts assume-role \
      --role-arn "$(terraform output -raw test_role_arn)" \
      --role-session-name session-limited \
      --policy '{
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::455394301478-23-iam-policy-evaluation-mix-bucket/*"
          }
        ]
      }')

Export the temporary credentials:

    export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')

## Resource policy

The S3 bucket policy contains an explicit deny for:

- `s3:PutObject`

for the test role.

## Test

`GetObject` succeeds:

    aws s3api get-object \
      --bucket "$(terraform output -raw s3_bucket)" \
      --key tmp/test.txt \
      /tmp/test.txt

`PutObject` fails:

    aws s3api put-object \
      --bucket "$(terraform output -raw s3_bucket)" \
      --key tmp/new.txt \
      --body /tmp/test.txt

AWS reports that `PutObject` was blocked by an explicit deny in a resource-based policy.

## Result

Effective permissions are determined by all applicable policy layers.

The final scenario contains:

- identity policy: allows `GetObject` and `PutObject`
- permissions boundary: allows `GetObject` and `PutObject`
- session policy: allows only `GetObject`
- resource policy: explicitly denies `PutObject`

`GetObject` succeeds and `PutObject` is denied.

An explicit `Deny` always overrides an `Allow`, including when the deny comes from a resource-based policy.
