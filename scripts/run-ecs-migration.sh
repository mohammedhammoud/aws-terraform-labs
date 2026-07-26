#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
TF_DIR="${TF_DIR:-$SCRIPT_DIR/../infra/ecs-fargate/terraform}"
AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-eu-north-1}}"

terraform_output_json() {
  terraform -chdir="$TF_DIR" output -json "$1"
}

require_value() {
  local name="$1"
  local value="$2"

  if [ -z "$value" ]; then
    echo "Missing required value: $name" >&2
    exit 1
  fi
}

ECS_CLUSTER_NAME="${ECS_CLUSTER_NAME:-$(terraform -chdir="$TF_DIR" output -raw ecs_cluster_name)}"
MIGRATION_TASK_DEFINITION_ARN="${MIGRATION_TASK_DEFINITION_ARN:-$(terraform -chdir="$TF_DIR" output -raw backend_migration_task_definition_arn)}"
BACKEND_SECURITY_GROUP_ID="${BACKEND_SECURITY_GROUP_ID:-$(terraform -chdir="$TF_DIR" output -raw backend_security_group_id)}"
PRIVATE_SUBNET_IDS="${PRIVATE_SUBNET_IDS:-$(terraform_output_json private_subnet_ids | python3 -c 'import json,sys; print(",".join(json.load(sys.stdin)))')}"

require_value AWS_REGION "$AWS_REGION"
require_value ECS_CLUSTER_NAME "$ECS_CLUSTER_NAME"
require_value MIGRATION_TASK_DEFINITION_ARN "$MIGRATION_TASK_DEFINITION_ARN"
require_value BACKEND_SECURITY_GROUP_ID "$BACKEND_SECURITY_GROUP_ID"
require_value PRIVATE_SUBNET_IDS "$PRIVATE_SUBNET_IDS"

RUN_TASK_OUTPUT="$(aws ecs run-task \
  --region "$AWS_REGION" \
  --cluster "$ECS_CLUSTER_NAME" \
  --launch-type FARGATE \
  --task-definition "$MIGRATION_TASK_DEFINITION_ARN" \
  --network-configuration "awsvpcConfiguration={subnets=[$PRIVATE_SUBNET_IDS],securityGroups=[$BACKEND_SECURITY_GROUP_ID],assignPublicIp=DISABLED}" \
  --output json)"

RUN_TASK_FAILURES="$(printf '%s' "$RUN_TASK_OUTPUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); print(len(data.get("failures", [])))')"
if [ "$RUN_TASK_FAILURES" != "0" ]; then
  printf '%s\n' "$RUN_TASK_OUTPUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); print(json.dumps(data.get("failures", []), indent=2))' >&2
  exit 1
fi

TASK_ARN="$(printf '%s' "$RUN_TASK_OUTPUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); tasks=data.get("tasks", []); print(tasks[0]["taskArn"] if tasks else "")')"
require_value TASK_ARN "$TASK_ARN"

aws ecs wait tasks-stopped \
  --region "$AWS_REGION" \
  --cluster "$ECS_CLUSTER_NAME" \
  --tasks "$TASK_ARN"

DESCRIBE_TASK_OUTPUT="$(aws ecs describe-tasks \
  --region "$AWS_REGION" \
  --cluster "$ECS_CLUSTER_NAME" \
  --tasks "$TASK_ARN" \
  --output json)"

STOPPED_REASON="$(printf '%s' "$DESCRIBE_TASK_OUTPUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); tasks=data.get("tasks", []); print(tasks[0].get("stoppedReason", "") if tasks else "")')"
CONTAINER_EXIT_CODE="$(printf '%s' "$DESCRIBE_TASK_OUTPUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); tasks=data.get("tasks", []); containers=tasks[0].get("containers", []) if tasks else []; exit_code=containers[0].get("exitCode") if containers else ""; print("" if exit_code is None else exit_code)')"
CONTAINER_REASON="$(printf '%s' "$DESCRIBE_TASK_OUTPUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); tasks=data.get("tasks", []); containers=tasks[0].get("containers", []) if tasks else []; print(containers[0].get("reason", "") if containers else "")')"

if [ "$CONTAINER_EXIT_CODE" != "0" ]; then
  echo "Migration failed. taskArn=$TASK_ARN stoppedReason=$STOPPED_REASON containerReason=$CONTAINER_REASON exitCode=${CONTAINER_EXIT_CODE:-missing}" >&2
  exit 1
fi

echo "Migration succeeded. taskArn=$TASK_ARN exitCode=0"
