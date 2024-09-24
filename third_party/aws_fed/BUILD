filegroup(
    name = "aws_fed",
    srcs = [
        "aws-fed.toml",
        "federate.sh",
    ],
    visibility = ["PUBLIC"],
)

sh_binary(
    deps = [":aws_fed"],
    main = "federate.sh",
    name = "federate",
    visibility = ["PUBLIC"],
)
