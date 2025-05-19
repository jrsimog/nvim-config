vim.g.projectionist_heuristics = {
    ["*.ex"] = {
        ["mix.exs"] = {
            alternate = "test/{}_test.exs",
            type = "source",
        },
        ["test/*_test.exs"] = {
            alternate = "lib/{}.ex",
            type = "test",
        },
    },
    ["*.php"] = {
        ["src/*.php"] = {
            alternate = {
                "tests/{}_Test.php",
                "tests/{}_TestCase.php",
            },
            type = "source",
        },
        ["tests/*_Test.php"] = {
            alternate = "src/{}.php",
            type = "test",
        },
    },
}
