#!/usr/bin/env bash
set -euo pipefail

ACTIONS=(init fmt validate plan apply destroy)
ACTION="${1:-plan}"

is_action() {
  local value="$1"

  for action in "${ACTIONS[@]}"; do
    if [ "$action" = "$value" ]; then
      return 0
    fi
  done

  return 1
}

has_tf_files() {
  local dir="$1"

  [ -d "$dir" ] || return 1
  compgen -G "$dir"'/*.tf' > /dev/null
}

resolve_tf_dir_from_cwd() {
  local dir
  dir="$(pwd -P)"

  if has_tf_files "$dir"; then
    printf '%s\n' "$dir"
    return 0
  fi

  if has_tf_files "$dir/terraform"; then
    printf '%s\n' "$dir/terraform"
    return 0
  fi

  return 1
}

if ! is_action "$ACTION"; then
  echo "Unknown action: $ACTION"
  echo "Allowed: init, fmt, validate, plan, apply, destroy"
  exit 1
fi

if ! TF_DIR="$(resolve_tf_dir_from_cwd)"; then
  echo "Could not find Terraform config from current directory: $(pwd -P)"
  echo "Run this from a project directory or its terraform/ directory."
  echo "Example: ../../tools/tf.sh plan"
  exit 1
fi

cd "$TF_DIR"

echo "Using Terraform directory: $TF_DIR"

case "$ACTION" in
  init)
    terraform init
    ;;
  fmt)
    terraform fmt
    ;;
  validate)
    terraform init
    terraform validate
    ;;
  plan)
    terraform fmt
    terraform init
    terraform validate
    terraform plan
    ;;
  apply)
    terraform fmt
    terraform init
    terraform validate
    terraform apply
    ;;
  destroy)
    terraform init
    terraform destroy
    ;;
esac
