# IAM Policy Evaluation Mix

Terraform lab for testing how multiple IAM policy types interact.

The lab creates:

- an IAM role
- an S3 bucket with a test object
- an identity policy
- a permissions boundary
- an S3 bucket policy
- a session policy passed during `AssumeRole`

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

This limits the temporary session to `GetObject`.

## Resource policy

The S3 bucket policy contains an explicit deny for:

- `s3:PutObject`

for the test role.

## Test result

After assuming the role with the limited session policy:

- `GetObject` succeeds
- `PutObject` fails

AWS reports that `PutObject` was blocked by an explicit deny in a resource-based policy.

## Result

Effective permissions are determined by all applicable policy layers.

Identity policies grant permissions, while permissions boundaries and session policies can restrict them further.

An explicit `Deny` always overrides an `Allow`, including when the deny comes from a resource-based policy.
