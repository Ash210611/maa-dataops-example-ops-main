#!/bin/bash
set -e -o pipefail

export MODULE_NAME="${1:-pipeline_infra}"
export ENV="${2:-local}"
export REGION="${3:-us-east-1}"
export TDV_ENV="${4:-dev}"
export WAIT_TIME="${5:-default}"
export PROJECT_NAME="${6:-default}"
export TERRAGRUNT_PARALLELISM="${7:-3}"

echo "JOB INFO:: PVS Test"

cd "$(dirname "${0}")/commands" || true
source pre.sh
cd ..

pip install poetry
#poetry -C scripts/toml_utilities install
poetry -C scripts/airflow_dag_runner install
#
#poetry -C scripts/toml_utilities run obtain_build_config terraform_yaml_config git_repo --ops_type dml_with_dag > solution_repo_config.yaml
#cat solution_repo_config.yaml #(maybe debug only?)
#
#pushd "module/aws"
#
#export MWAA_ENV=$(jq -r '.aws_mwaa_environment_name.value' output.json)
#export REGION=$(jq -r '.aws_region.value' output.json)
#export ENV=$(jq -r '.env.value' output.json)
#export SECRETS_MANAGER=$(jq -r '.secrets_name.value' output.json)
#export TDV_DML_WITH_DAG_S3_PATHS=$(jq -r '.moduleyamlcustomdml.value | .[] | select(.type=="dml_with_dag") | .output_prefix' output.json)
#popd

export MWAA_ENV=maa-medicare-advantage-airflow-cluster-dev
export SECRETS_MANAGER=maa-tdv-sa-SVT_DATAOPS_DEV-maa-dataops-example-solutions-pvs_dag
export TDV_DML_WITH_DAG_S3_PATHS=maa-dataops-example-solutions/dataops_custom_dags/pvs_dag



echo "-- Export Values:"
echo "MWAA_ENV=${MWAA_ENV}"
echo "REGION=${REGION}"
echo "AWS ENV=${ENV}"
echo "TDV_ENV=${TDV_ENV}"
echo "SECRETS_MANAGER=${SECRETS_MANAGER}"
echo "TDV_DML_WITH_DAG_S3_PATHS=${TDV_DML_WITH_DAG_S3_PATHS}"
echo "WAIT_TIME=${WAIT_TIME}"
echo "DAG_ID=${DAG_ID}"

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
    --liquibase_cmd="update" \
    --wait_time="${WAIT_TIME}"
}

S3_PATHS=("${TDV_DML_WITH_DAG_S3_PATHS[@]}")

for s3_path in "${S3_PATHS[@]}"; do
  if [[ -z "$s3_path" || "$s3_path" == " " ]]; then
    continue
  fi
  run_poetry_command "${s3_path}" "data_ops_pvs_dag"
done