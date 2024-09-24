#!/usr/bin/env bash
set -e -o pipefail

OPS_REPO_PATH="${1}"
SOLUTIONS_DDL_LIST="${2}"

export WORKSPACE=$PWD
export NUM_FAILED=0
echo "WORKSPACE: ${WORKSPACE}"

generate_ini_file() {
  local ini_file=$1
  local ddl_dir=$2
  local xml_file=$3

  # overwrite contents of ini file if exists >
  echo "[UN_RE]" > ${INI_FILE}

  # and now append to ini >>
  echo "PARALLEL_DEGREE = 8" >> ${INI_FILE}
  echo "VERBOSE = 1" >> ${INI_FILE}
  
  echo "INPUT_SQL_DIR = $ddl_dir/tables" >> ${INI_FILE}
  echo "XML_FILENAME = $ddl_dir/$xml_file" >> ${INI_FILE}
  echo "RULES_ENGINE_TYPE = TERADATA_DDL" >> ${INI_FILE}

  cat $INI_FILE
}

#sep
IFS=':'

#dir1:dir2 to array
read -ra ddl_dirs <<< "$SOLUTIONS_DDL_LIST"

# loop through ddl dirs and run rules
for ddl_dir in "${ddl_dirs[@]}"; do
  echo "$ddl_dir"

  # create empty property file
  PROPERTY_FILE=$OPS_REPO_PATH/$ddl_dir/Rules_Engine.properties
  touch "$PROPERTY_FILE"

  # create ini file
  INI_FILE=$OPS_REPO_PATH/$ddl_dir/rules.ini
  touch "$INI_FILE"

  export XML_DIR=$OPS_REPO_PATH/$ddl_dir
  export XML_FILE="${TDV_ENV}.changelog.xml"
  export LOG_FILE=$OPS_REPO_PATH/$ddl_dir/Rules_Engine.log

  generate_ini_file ${INI_FILE} $OPS_REPO_PATH/$ddl_dir ${XML_FILE}
  poetry run run_rules -i ${INI_FILE} -v | tee ${LOG_FILE}
done

## error/warnings to .txt
error_log_filepath=${WORKSPACE}/errors.txt
touch "${error_log_filepath}"

warning_log_filepath=${WORKSPACE}/warnings.txt
touch "${warning_log_filepath}"

echo "`cat ${WORKSPACE}/tmp/*/Rules_Engine.errors`" > $error_log_filepath
echo "`cat ${WORKSPACE}/tmp/*/Rules_Engine.warnings`" > $warning_log_filepath

poetry run parse_rules_engine_logs --file_path="${error_log_filepath}"