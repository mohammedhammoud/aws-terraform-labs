# IAM Permission Boundaries

This lab shows how a permission boundary limits what an IAM role can do.

## Setup

Terraform creates:

- Role 1
- a policy for Role 1
- a boundary for Role 1
- a boundary for Role 2

Role 2 is created manually with the AWS CLI.

Role 1 can:

- create `permission-boundaries-role-2`
- create it only if the correct boundary is added
- attach policies to Role 2

Role 2's boundary only allows:

```text
s3:GetObject
```

## Tests

### Create Role 2 without a boundary

This failed.

Role 1 was not allowed to create Role 2 without the required boundary.

### Create Role 2 with the correct boundary

This worked.

### Attach AdministratorAccess

`AdministratorAccess` was attached to Role 2.

Even though AdministratorAccess was attached to Role 2, the boundary still limited what it could do.

### Test EC2 access

After assuming Role 2, this command failed:

```bash
aws ec2 describe-instances
```

AWS returned:

```text
because no permissions boundary allows the ec2:DescribeInstances action
```

## Result

Role 2 had:

```text
AdministratorAccess
```

But the maximum permissions allowed by its boundary were:

```text
s3:GetObject
```

The EC2 action was denied even though `AdministratorAccess` allowed it.

A permission boundary does not give permissions.

It only sets the maximum permissions a role can receive.

## Cleanup

Role 2 and `AdministratorAccess` were created manually, so Terraform will not remove them.

Run:

```bash
aws iam detach-role-policy \
  --role-name permission-boundaries-role-2 \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

aws iam delete-role \
  --role-name permission-boundaries-role-2

terraform destroy
```
