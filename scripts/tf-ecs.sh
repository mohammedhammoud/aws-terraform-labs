#!/usr/bin/env bash
set -euo pipefail

if (($# < 2)); then
  echo "Usage: $0 <dev|stage|prod> <terraform-command> [args...]" >&2
  exit 1
fi

environment="$1"
command="$2"
shift 2

case "$environment" in
  dev|stage|prod) ;;
  *)
    echo "Invalid environment: $environment" >&2
    exit 1
    ;;
esac

stack_root="$(pwd -P)"
stack_name="$(basename "$stack_root")"
tf_dir="$stack_root/terraform"
backend_key="aws-terraform-labs/${stack_name}/${environment}/terraform.tfstate"

if [[ ! -d "$tf_dir" ]]; then
  echo "Terraform directory not found: $tf_dir" >&2
  exit 1
fi

init_backend() {
  terraform -chdir="$tf_dir" init \
    -reconfigure \
    -backend-config="key=${backend_key}" \
    -input=false
}

case "$command" in
  fmt)
    terraform -chdir="$tf_dir" fmt "$@"
    ;;
  validate)
    init_backend
    terraform -chdir="$tf_dir" validate "$@"
    ;;
  plan|apply|destroy|refresh)
    init_backend
    terraform -chdir="$tf_dir" "$command" "$@" -var="environment=${environment}"
    ;;
  *)
    echo "Unsupported Terraform command: $command" >&2
    echo "Supported commands: fmt, validate, plan, apply, destroy, refresh" >&2
    exit 1
    ;;
esac
