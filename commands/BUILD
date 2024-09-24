filegroup(
    name = "commands",
    srcs = glob([
        "*.sh",
    ]),
    visibility = ["PUBLIC"],
)

sh_binary(
    deps = [
        "//commands:commands",
        "//:obtain_solutions",
        "//third_party/aws_fed:aws_fed",
        "//module:terraform",
        "//scripts:toml_utilities",
    ],
    data= [
        "//commands:commands",
        "//:obtain_solutions",
        "//third_party/aws_fed:aws_fed",
        "//module:terraform",
        "//scripts:toml_utilities",
    ],
    main = "plan_all.sh",
    name = "plan_all",
)

sh_binary(
    deps = [
        "//commands:commands",
        "//:obtain_solutions",
        "//third_party/aws_fed:aws_fed",
        "//module:terraform",
        "//scripts:toml_utilities",
        "//scripts:airflow_dag_runner",
    ],
    data= [
        "//commands:commands",
        "//:obtain_solutions",
        "//third_party/aws_fed:aws_fed",
        "//module:terraform",
        "//scripts:toml_utilities",
        "//scripts:airflow_dag_runner",
    ],
    main = "apply_all.sh",
    name = "apply_all",
)

sh_binary(
    deps = [
        "//commands:commands",
        "//:obtain_solutions",
        "//third_party/aws_fed:aws_fed",
        "//module:terraform",
        "//scripts:toml_utilities",
    ],
    data= [
        "//commands:commands",
        "//:obtain_solutions",
        "//third_party/aws_fed:aws_fed",
        "//module:terraform",
        "//scripts:toml_utilities",
    ],
    main = "destroy_all.sh",
    name = "destroy_all",
)

sh_binary(
    deps = [
        "//commands:commands",
        "//:obtain_solutions",
        "//third_party/aws_fed:aws_fed",
        "//module:terraform",
        "//scripts:toml_utilities",
        "//scripts:airflow_dag_runner",
    ],
    data= [
        "//commands:commands",
        "//:obtain_solutions",
        "//third_party/aws_fed:aws_fed",
        "//module:terraform",
        "//scripts:toml_utilities",
        "//scripts:airflow_dag_runner",
    ],
    main = "rollback_all.sh",
    name = "rollback_all",
)
