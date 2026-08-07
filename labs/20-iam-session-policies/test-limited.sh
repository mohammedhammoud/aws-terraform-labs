#!/usr/bin/env bash
set -euo pipefail

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

ROLE_ARN="$(terraform -chdir=terraform output -raw test_role_arn)"
BUCKET="$(terraform -chdir=terraform output -raw s3_bucket)"

CREDS="$(aws sts assume-role \
  --role-arn "$ROLE_ARN" \
  --role-session-name session-policy-limited \
  --policy "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [{
      \"Effect\": \"Allow\",
      \"Action\": \"s3:GetObject\",
      \"Resource\": \"arn:aws:s3:::$BUCKET/*\"
    }]
  }")"

export AWS_ACCESS_KEY_ID="$(jq -r '.Credentials.AccessKeyId' <<< "$CREDS")"
export AWS_SECRET_ACCESS_KEY="$(jq -r '.Credentials.SecretAccessKey' <<< "$CREDS")"
export AWS_SESSION_TOKEN="$(jq -r '.Credentials.SessionToken' <<< "$CREDS")"

aws sts get-caller-identity

aws s3api get-object \
  --bucket "$BUCKET" \
  --key tmp/test.txt \
  /tmp/session-limited-get.txt

aws s3api put-object \
  --bucket "$BUCKET" \
  --key tmp/session-limited-put.txt \
  --body /tmp/session-limited-get.txt
