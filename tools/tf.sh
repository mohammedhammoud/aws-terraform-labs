#!/usr/bin/env bash
set -euo pipefail

ACTIONS=(init fmt validate plan apply apply-auto destroy)
ACTION="${1:-plan}"

if (($# > 0)); then
  shift
fi

declare -a TF_ARGS=()

if (($# > 0)); then
  TF_ARGS=("$@")
fi

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

run_tf() {
  local command="$1"
  shift

  if ((${#TF_ARGS[@]} > 0)); then
    terraform "$command" "$@" "${TF_ARGS[@]}"
  else
    terraform "$command" "$@"
  fi
}

if ! is_action "$ACTION"; then
  echo "Unknown action: $ACTION"
  echo "Allowed: init, fmt, validate, plan, apply, apply-auto, destroy"
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
    run_tf init
    ;;

  fmt)
    run_tf fmt
    ;;

  validate)
    terraform init
    run_tf validate
    ;;

  plan)
    terraform fmt
    terraform init
    terraform validate
    run_tf plan
    ;;

  apply)
    terraform fmt
    terraform init
    terraform validate
    run_tf apply
    ;;

  apply-auto)
    terraform fmt
    terraform init
    terraform validate
    run_tf apply -auto-approve
    ;;

  destroy)
    terraform init
    run_tf destroy
    ;;
esac