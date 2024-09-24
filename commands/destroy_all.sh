#!/bin/bash
set -e -o pipefail

export MODULE_NAME="${1:-pipeline_infra}"
export ENV="${2:-local}"
export REGION="${3:-us-east-1}"
export TDV_ENV="${4:-dev}"
export OPS_TYPE="${5:-all}"
export ASSIGN_TAG="${6:-false}"
export LIQUIBASE_TAG="${7:-default}"
export DAGID="${8:-default}"
export WAIT_TIME="${9:-default}"
export PROJECT_NAME="${10:-default}"
export TERRAGRUNT_PARALLELISM="${11:-3}"

echo "JOB INFO:: destroying modules"

cd "$(dirname "${0}")/commands" || true
source pre.sh
cd ..
ls -l

if [[ ! -f "solution_repo_config.yaml" ]]; then
  touch config.yaml
  cat << EOF >> solution_repo_config.yaml
ddl: []
tdv_ddl: []
tdv_dml: []
dml_with_dag: []
stored_proc: []
EOF
fi

export REPO_PATH="${PWD}"

pushd "module/aws"
source <(tfenv)
terragrunt run-all destroy ${DEFAULT_TFTG_CLI_ARGS}
popd
