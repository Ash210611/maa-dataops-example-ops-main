#!/usr/bin/env bash
set -ex

function test_individual_module() {
    echo "[INFO]: test test_individual_module - ${MODULE}"
    local MODULE=$1 src_path=$2
    local report_path=reports

    echo "test_individual_module working directory: $PWD"
    pushd "${MODULE}/"

    poetry install

    mkdir -p ${report_path}
    echo "report path: ${report_path}"

    poetry run pytest -rP #--cov=${src_path} --cov-report=xml:${report_path}/coverage.xml --junitxml=${report_path}/tests.xml
    popd
}