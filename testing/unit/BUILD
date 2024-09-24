sh_test(
    src = "unit_test.sh",
    deps= ["//:setup_test_env", "//:obtain_solutions", "//scripts:toml_utilities", "//commands:commands"],
    data= ["//:obtain_solutions", "//scripts:toml_utilities", "//commands:commands"],
    name = "10_unit_test",
    timeout = 2000,
    labels = ["unit"],

)
