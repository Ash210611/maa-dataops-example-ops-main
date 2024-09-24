#!/bin/bash
set -e -o pipefail

export MODULE_NAME="${1:-pipeline_infra}"
export ENV="${2:-local}"
export REGION="${3:-us-east-1}"
export TDV_ENV="${4:-dev}"
export OPS_TYPE="${5:-all}"
export ASSIGN_TAG="${6:-true}" # ignore this argument; not in use
export LIQUIBASE_TAG="${7:-default}"
export PROJECT_NAME="${8:-default}"
export TERRAGRUNT_PARALLELISM="${9:-3}"

echo "JOB INFO:: rollback modules"

cd "$(dirname "${0}")/commands" || true
source pre.sh
cd ..

pip install poetry
poetry -C scripts/toml_utilities install
poetry -C scripts/airflow_dag_runner install

poetry -C scripts/toml_utilities run obtain_build_config terraform_yaml_config git_repo --ops_type ${OPS_TYPE} > solution_repo_config.yaml
cat solution_repo_config.yaml #(maybe debug only?)

export REPO_PATH="${PWD}/git_repo"

pushd "module/aws"
source <(tfenv)
terragrunt run-all apply ${TFTG_CLI_ARGS_APPLY_MODULE}
terragrunt run-all output -json | tee output.json

export MWAA_ENV=$(jq -r '.aws_mwaa_environment_name.value' output.json)
export REGION=$(jq -r '.aws_region.value' output.json)
export ENV=$(jq -r '.env.value' output.json)
export SECRETS_MANAGER=$(jq -r '.secrets_name.value' output.json)
export TDV_DDL_S3_PATHS=$(jq -r '.moduleyamlddl.value | .[] | select(.type=="tdv_ddl") | .output_prefix' output.json)
export TDV_DML_S3_PATHS=$(jq -r '.moduleyamldml.value | .[] | select(.type=="tdv_dml") | .output_prefix' output.json)
export TDV_DML_WITH_DAG_S3_PATHS=$(jq -r '.moduleyamlcustomdml.value | .[] | select(.type=="dml_with_dag") | .output_prefix' output.json)
#export TDV_STORED_PROC_S3_PATHS=$(jq -r '.moduleyamlsp.value | .[] | select(.type=="stored_proc") | .output_prefix' output.json)
popd

echo "-- Export Values:"
echo "MWAA_ENV=${MWAA_ENV}"
echo "REGION=${REGION}"
echo "AWS ENV=${ENV}"
echo "TDV_ENV=${TDV_ENV}"
echo "SECRETS_MANAGER=${SECRETS_MANAGER}"
echo "LIQUIBASE_TAG=${LIQUIBASE_TAG}"
echo "TDV_DDL_S3_PATHS=${TDV_DDL_S3_PATHS} "
echo "TDV_DML_S3_PATHS=${TDV_DML_S3_PATHS}"
echo "TDV_DML_WITH_DAG_S3_PATHS=${TDV_DML_WITH_DAG_S3_PATHS}"
echo "TDV_STORED_PROC_S3_PATHS=${TDV_STORED_PROC_S3_PATHS}"

run_poetry_command() {
  local s3_path=$1
  local dag_id=$2
  echo "Run DAG for S3=${s3_path}"
  poetry -C scripts/airflow_dag_runner run trigger_dag_and_monitor \
    --mwaa_env="${MWAA_ENV}" \
    --region="${REGION}" \
    --dag_id="${dag_id}" \
    --s3_path="${s3_path}" \
    --secrets_manager_name="${SECRETS_MANAGER}" \
    --bucket_env="${ENV}" \
    --liquibase_cmd="rollback --tag=${LIQUIBASE_TAG}"
}

case ${OPS_TYPE} in
  all)
    S3_PATHS=("${TDV_DDL_S3_PATHS[@]}" "${TDV_DML_S3_PATHS[@]}" "${TDV_STORED_PROC_S3_PATHS[@]}")
    ;;
#  all)
#    S3_PATHS=("${TDV_DDL_S3_PATHS[@]}" "${TDV_DML_S3_PATHS[@]}")
#    ;;
  tdv_ddl)
    S3_PATHS=("${TDV_DDL_S3_PATHS[@]}")
    ;;
  tdv_dml)
    S3_PATHS=("${TDV_DML_S3_PATHS[@]}")
    ;;
  stored_proc)
    S3_PATHS=("${TDV_STORED_PROC_S3_PATHS[@]}")
    ;;
  *)
    echo "Error: Invalid OPS_TYPE=${OPS_TYPE}"
    ;;
esac

for s3_path in "${S3_PATHS[@]}"; do
  if [[ -z "$s3_path" || "$s3_path" == " " ]]; then
    continue
  fi
  run_poetry_command "${s3_path}" "${DAG_ID}"
done
