#!/usr/bin/env bash
set -ex

source commands/test_funcs.sh

export PATH=$HOME/.local/bin:$PATH

poetry -C ./scripts/toml_utilities install
DIRECTORIES=$(poetry -C ./scripts/toml_utilities run obtain_build_config directory_types git_repo --ops_type ddl)

if [ -z "$DIRECTORIES" ]
then
      echo "\$DIRECTORIES is empty, likely an error"
      exit 1
fi

IFS=':' read -r -a directories <<< $DIRECTORIES

for dir in "${directories[@]}"; do
  echo "Running tests in $dir"
  test_individual_module "$dir"
done
