# IAM Resource Policy Conditions

This lab shows how a resource policy condition can control which IAM role is allowed to access an S3 object.

## Setup

Terraform creates:

- an S3 bucket
- a test object
- a `test` role
- an `other` role
- an S3 bucket policy

The bucket policy uses:

```text
Principal = "*"
```

but adds a condition:

```text
aws:PrincipalArn == test role ARN
```

This means the statement only applies when the request comes from the `test` role.

## Tests

Two scripts are used:

```text
test-allowed.sh
test-denied.sh
```

### Allowed role

`test-allowed.sh` assumes the `test` role.

The role has no identity policy that allows `s3:GetObject`.

The bucket policy allows the request because:

```text
aws:PrincipalArn
```

matches the `test` role ARN.

`GetObject` worked.

### Denied role

`test-denied.sh` assumes the `other` role.

The `other` role also has no identity policy that allows `s3:GetObject`.

The bucket policy statement does not apply because its `aws:PrincipalArn` does not match the required role ARN.

`GetObject` was denied.

## Result

A resource policy can grant access even when the IAM role itself has no identity policy for that action.

Using:

```text
Principal = "*"
```

does not automatically mean everyone gets access.

The condition can add extra requirements that must be true before the statement applies.

In this lab:

```text
test role  -> condition matches     -> allowed
other role -> condition does not match -> denied
```
