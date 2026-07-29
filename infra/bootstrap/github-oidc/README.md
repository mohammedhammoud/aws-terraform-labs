# GitHub OIDC bootstrap with Terraform

Bootstrap Terraform for GitHub Actions OIDC access to AWS.

## Resources

- GitHub OIDC provider
- GitHub Actions apply role
- GitHub Actions plan role
- Trust policy for this repo, branch, environments, and PRs

## Trust policy

```text
aud = sts.amazonaws.com
apply = repo:mohammedhammoud@5408383/aws-terraform-labs@1293580188:ref:refs/heads/master
apply = repo:mohammedhammoud@5408383/aws-terraform-labs@1293580188:environment:dev
apply = repo:mohammedhammoud@5408383/aws-terraform-labs@1293580188:environment:stage
apply = repo:mohammedhammoud@5408383/aws-terraform-labs@1293580188:environment:prod
plan = repo:mohammedhammoud@5408383/aws-terraform-labs@1293580188:pull_request
```

## Outputs

- `github_actions_apply_role_arn`
- `github_actions_plan_role_arn`

## Run

From `infra/bootstrap/github-oidc`:

```sh
../../../tools/tf.sh init
../../../tools/tf.sh plan
../../../tools/tf.sh apply
```

Set `github_environments` to the exact GitHub Environments allowed to assume the apply role.
