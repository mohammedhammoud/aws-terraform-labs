# IAM Policy Evaluation

A small lab for understanding how AWS IAM decides whether an action is allowed or denied.

## What this lab shows

- A trust policy controls who can assume a role.
- An identity policy controls what the role can do.
- A bucket policy controls who can access the bucket.
- Everything is denied by default.
- An explicit deny always wins.
- A permission boundary sets the maximum permissions for the role.

## Resources

- One S3 bucket
- `allowed/read-me.txt`
- `private/secret.txt`
- One IAM role
- One policy attached to the role
- One bucket policy
- One permission boundary

## Tests

1. The role had no S3 permissions.  
   Both objects were denied.

2. The role was allowed to read `allowed/*`.  
   `allowed/*` worked and `private/*` was denied.

3. The bucket policy allowed the role to read `private/*`.  
   Both objects worked.

4. The role had an explicit deny for `private/*`.  
   `private/*` was denied even though the bucket policy allowed it.

5. The permission boundary allowed only `allowed/*`.  
   `allowed/*` worked and `private/*` was denied.

6. The bucket policy pointed directly to the session ARN.  
   `private/*` worked despite the boundary.

The final setup uses the role ARN in the bucket policy. The session ARN was only used for testing.

## Simple model

```text
Trust policy:
Who can assume the role?

Identity policy:
What can the role do?

Bucket policy:
What does the bucket allow?

Permission boundary:
What is the maximum the role can do?
```
