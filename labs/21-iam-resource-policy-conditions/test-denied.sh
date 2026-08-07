#!/usr/bin/env bash
set -euo pipefail

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

ROLE_ARN="$(terraform -chdir=terraform output -raw other_role_arn)"
BUCKET="$(terraform -chdir=terraform output -raw s3_bucket)"

CREDS="$(aws sts assume-role \
  --role-arn "$ROLE_ARN" \
  --role-session-name resource-policy-denied)"

export AWS_ACCESS_KEY_ID="$(jq -r '.Credentials.AccessKeyId' <<< "$CREDS")"
export AWS_SECRET_ACCESS_KEY="$(jq -r '.Credentials.SecretAccessKey' <<< "$CREDS")"
export AWS_SESSION_TOKEN="$(jq -r '.Credentials.SessionToken' <<< "$CREDS")"

aws sts get-caller-identity

if aws s3api get-object \
  --bucket "$BUCKET" \
  --key tmp/test.txt \
  /tmp/resource-policy-denied.txt; then
  exit 1
fi
