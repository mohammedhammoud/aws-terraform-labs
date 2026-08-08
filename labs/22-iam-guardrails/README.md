# IAM Guardrails

Terraform lab for testing IAM guardrails using explicit deny.

The lab creates:

- an IAM role
- an S3 bucket with a test object
- a broad access policy allowing:
  - `s3:GetObject`
  - `s3:PutObject`
  - `s3:DeleteObject`
- a separate guardrail policy explicitly denying:
  - `s3:DeleteObject`

Both policies are attached to the same role.

## Test

After assuming the role:

- `GetObject` succeeds
- `PutObject` succeeds
- `DeleteObject` fails

The delete request is denied even though another policy explicitly allows it.

AWS returns an error showing that the request was blocked by an explicit deny in the guardrail policy.

## Result

An explicit `Deny` always overrides an `Allow`.

This makes explicit deny useful as a guardrail when a role already has broad permissions from another policy.
