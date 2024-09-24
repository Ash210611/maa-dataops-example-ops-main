filegroup(
    name = "toml_utilities",
    srcs = glob(["toml_utilities/*",]),
    visibility = ["PUBLIC"],
)

filegroup(
    name = "airflow_dag_runner",
    srcs = glob(["airflow_dag_runner/*",]),
    visibility = ["PUBLIC"],
)

sh_test(
    src = "ops_test.sh",
    deps= ["//:setup_test_env", "//commands:commands", ":toml_utilities", ":airflow_dag_runner"],
    data= ["//:setup_test_env", "//commands:commands", ":toml_utilities", ":airflow_dag_runner"],
    name = "00_opsTest",
    timeout = 2000,
    labels = ["unit"],
)