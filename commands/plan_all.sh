#!/bin/bash
set -e -o pipefail

export MODULE_NAME="${1:-pipeline_infra}"
export ENV="${2:-local}"
export REGION="${3:-us-east-1}"
export TDV_ENV="${4:-dev}"
export OPS_TYPE="${5:-all}"
export PROJECT_NAME="${6:-default}"
export TERRAGRUNT_PARALLELISM="${7:-3}"

echo "JOB INFO:: planning modules"
echo "-- Export Values:"
echo "MODULE_NAME=${MODULE_NAME}"
echo "AWS ENV=${ENV}"
echo "REGION=${REGION}"
echo "TDV_ENV=${TDV_ENV}"

cd "$(dirname "${0}")/commands" || true
source pre.sh
cd ..
ls -l

pip install poetry
poetry -C scripts/toml_utilities install

poetry -C scripts/toml_utilities run obtain_build_config terraform_yaml_config git_repo --ops_type ${OPS_TYPE} > solution_repo_config.yaml
cat solution_repo_config.yaml #(maybe debug only?)

export REPO_PATH="${PWD}/git_repo"

pushd "module/aws"
source <(tfenv)
terragrunt run-all plan ${TFTG_CLI_ARGS_PLAN_ALL}
terragrunt run-all output -json | tee output.json
popd