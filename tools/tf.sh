#!/usr/bin/env bash
set -euo pipefail

ACTIONS=(init fmt validate plan apply apply-auto destroy refresh)
ENVIRONMENT=""
ACTION="plan"

declare -a TF_ARGS=()

declare -a POSITIONAL_ARGS=()

is_action() {
  local value="$1"

  for action in "${ACTIONS[@]}"; do
    if [ "$action" = "$value" ]; then
      return 0
    fi
  done

  return 1
}

is_environment() {
  local value="$1"

  case "$value" in
    dev|stage|prod)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

parse_args() {
  while (($# > 0)); do
    case "$1" in
      --env|-e)
        if (($# < 2)); then
          echo "Missing value for $1" >&2
          exit 1
        fi

        if ! is_environment "$2"; then
          echo "Invalid environment: $2" >&2
          exit 1
        fi

        ENVIRONMENT="$2"
        shift 2
        ;;
      *)
        POSITIONAL_ARGS+=("$1")
        shift
        ;;
    esac
  done

  if ((${#POSITIONAL_ARGS[@]} > 0)); then
    if is_action "${POSITIONAL_ARGS[0]}"; then
      ACTION="${POSITIONAL_ARGS[0]}"
      TF_ARGS=("${POSITIONAL_ARGS[@]:1}")
    elif is_environment "${POSITIONAL_ARGS[0]}"; then
      ENVIRONMENT="${POSITIONAL_ARGS[0]}"

      if ((${#POSITIONAL_ARGS[@]} > 1)); then
        ACTION="${POSITIONAL_ARGS[1]}"
        TF_ARGS=("${POSITIONAL_ARGS[@]:2}")
      fi
    else
      ACTION="${POSITIONAL_ARGS[0]}"
      TF_ARGS=("${POSITIONAL_ARGS[@]:1}")
    fi
  fi
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

  local -a args=("$@")

  if [[ -n "$ENVIRONMENT" ]] && [[ "$command" =~ ^(plan|apply|destroy|refresh)$ ]]; then
    args+=("-var=environment=${ENVIRONMENT}")
  fi

  if ((${#TF_ARGS[@]} > 0)); then
    terraform "$command" "${args[@]}" "${TF_ARGS[@]}"
  else
    terraform "$command" "${args[@]}"
  fi
}

init_backend() {
  if [[ -n "$ENVIRONMENT" ]]; then
    local stack_root stack_name backend_key

    stack_root="$(dirname "$TF_DIR")"
    stack_name="$(basename "$stack_root")"
    backend_key="aws-terraform-labs/${stack_name}/${ENVIRONMENT}/terraform.tfstate"

    terraform init \
      -reconfigure \
      -backend-config="key=${backend_key}" \
      -input=false
    return
  fi

  terraform init
}

parse_args "$@"

if ! is_action "$ACTION"; then
  echo "Unknown action: $ACTION"
  echo "Allowed: init, fmt, validate, plan, apply, apply-auto, destroy, refresh" >&2
  exit 1
fi

if ! TF_DIR="$(resolve_tf_dir_from_cwd)"; then
  echo "Could not find Terraform config from current directory: $(pwd -P)" >&2
  echo "Run this from a project directory or its terraform/ directory." >&2
  echo "Example: ../../tools/tf.sh plan" >&2
  exit 1
fi

cd "$TF_DIR"

echo "Using Terraform directory: $TF_DIR"

if [[ -n "$ENVIRONMENT" ]]; then
  echo "Using environment: $ENVIRONMENT"
fi

case "$ACTION" in
  init)
    init_backend
    ;;

  fmt)
    run_tf fmt
    ;;

  validate)
    init_backend
    run_tf validate
    ;;

  plan)
    terraform fmt
    init_backend
    terraform validate
    run_tf plan
    ;;

  apply)
    terraform fmt
    init_backend
    terraform validate
    run_tf apply
    ;;

  apply-auto)
    terraform fmt
    init_backend
    terraform validate
    run_tf apply -auto-approve
    ;;

  destroy)
    init_backend
    run_tf destroy
    ;;

  refresh)
    init_backend
    run_tf refresh
    ;;
esac