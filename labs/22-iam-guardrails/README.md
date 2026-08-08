# IAM Guardrails

Terraform lab for testing the guardrail pattern using an explicit deny.

The lab creates:

- an IAM role
- an S3 bucket with a test object
- a broad customer-managed identity policy allowing:
  - `s3:GetObject`
  - `s3:PutObject`
  - `s3:DeleteObject`
- a separate customer-managed identity policy acting as a guardrail and explicitly denying:
  - `s3:DeleteObject`

Both policies are attached to the same role.

## Guardrail

IAM does not have a separate policy type called a guardrail.

In this lab, the guardrail is implemented as a separate identity policy containing an explicit `Deny`.

The broad access policy allows `DeleteObject`, while the guardrail policy explicitly denies it.

## Assume the role

    CREDS=$(aws sts assume-role \
      --role-arn "$(terraform output -raw test_role_arn)" \
      --role-session-name guardrails-test)

Export the temporary credentials:

    export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')

Verify the active identity:

    aws sts get-caller-identity

## Test

`GetObject` succeeds:

    aws s3api get-object \
      --bucket "$(terraform output -raw s3_bucket)" \
      --key tmp/test.txt \
      /tmp/guardrail-get.txt

`PutObject` succeeds:

    aws s3api put-object \
      --bucket "$(terraform output -raw s3_bucket)" \
      --key tmp/new.txt \
      --body /tmp/guardrail-get.txt

`DeleteObject` fails:

    aws s3api delete-object \
      --bucket "$(terraform output -raw s3_bucket)" \
      --key tmp/new.txt

AWS reports that `DeleteObject` was blocked by an explicit deny in an identity-based policy.

## Result

The broad access policy allows:

- `GetObject`
- `PutObject`
- `DeleteObject`

The guardrail policy explicitly denies:

- `DeleteObject`

Effective result:

- `GetObject` succeeds
- `PutObject` succeeds
- `DeleteObject` fails

An explicit `Deny` always overrides an `Allow`.

This pattern can be used to prevent specific actions even when another policy grants broader permissions.
