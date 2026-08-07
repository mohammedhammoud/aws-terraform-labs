# IAM Session Policies

This lab shows how a session policy can limit the permissions of an assumed IAM role.

## Setup

Terraform creates:

- a test IAM role
- a trust policy that allows the current AWS identity to assume the role
- an inline identity policy that allows:
  - `s3:GetObject`
  - `s3:PutObject`
- an S3 bucket with a test object

The role itself can both read and write S3 objects.

## Tests

Two scripts are used:

```text
test-full.sh
test-limited.sh
```

### Full session

`test-full.sh` assumes the role without a session policy.

The role can:

```text
s3:GetObject
s3:PutObject
```

Both actions worked.

### Limited session

`test-limited.sh` assumes the same role with a session policy that only allows:

```text
s3:GetObject
```

The session could still read the object.

`PutObject` failed with:

```text
because no session policy allows the s3:PutObject action
```

## Result

The IAM role normally allows:

```text
s3:GetObject
s3:PutObject
```

The limited session only allows:

```text
s3:GetObject
```

A session policy does not add permissions.

It can only limit the permissions that the role already has.

The session policy only applies to that temporary session and does not change the IAM role itself.
