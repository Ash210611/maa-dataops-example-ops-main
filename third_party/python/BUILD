pip_library(
    name = "boto3",
    version = "1.9.245",
    visibility = ["PUBLIC"],
    deps = [":botocore", ":urllib3", ":dateutil", ":six", ":jmespath"],
    zip_safe = False,
)

pip_library(
    name = "botocore",
    version = "1.12.245",
)

pip_library(
    name = "urllib3",
    version = "1.25.6",
)

pip_library(
    name = "dateutil",
    package_name = "python-dateutil",
    version = "2.8.1",
)

pip_library(
    name = "six",
    version = "1.12.0",
#    outs = ["six.py"],
)

pip_library(
    name = "hcl",
    package_name = "pyhcl",
    version = "0.3.12",
    visibility = ["PUBLIC"],
    deps = [":ply"],
    zip_safe = False,
)

pip_library(
    name = "ply",
    version = "3.11",
)

pip_library(
    name = "jmespath",
    version = "0.9.3",
)
