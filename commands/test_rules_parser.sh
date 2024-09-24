#!/usr/bin/env bash
set -e -o pipefail

export WORKSPACE=$PWD

pushd $WORKSPACE/un_re/evaluate_output

poetry run parse_rules_engine_logs --file_path="parse_logs/example_logs/error_log.txt"