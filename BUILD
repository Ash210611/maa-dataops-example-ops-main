
filegroup(
    name = "dags",
    srcs = glob([
        "//commands/*"
    ]),
    visibility = ["PUBLIC"],
)

genrule(
    name = "obtain_solutions",
    deps= ["//commands:commands"],
    cmd = "bash commands/obtain_solutions.sh",
    outs  = ["git_repo"],
    visibility = ["PUBLIC"],
)

genrule(
    name = "setup_test_env",
    deps= ["//commands:commands"],
    cmd = "bash commands/setup_test_env.sh",
    outs  = ["filename"],
    visibility = ["PUBLIC"],
)

