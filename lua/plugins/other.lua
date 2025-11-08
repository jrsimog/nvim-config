return {
  "rgroli/other.nvim",
  keys = {
    { "<leader>pa", "<cmd>Other<cr>", desc = "Alternate file" },
    { "<leader>pas", "<cmd>OtherSplit<cr>", desc = "Alternate file (split)" },
    { "<leader>pav", "<cmd>OtherVSplit<cr>", desc = "Alternate file (vsplit)" },
    { "<leader>pac", "<cmd>OtherClear<cr>", desc = "Clear alternate cache" },
  },
  config = function()
    require("other-nvim").setup({
      mappings = {
        {
          pattern = "/lib/(.*).ex$",
          target = "/test/%1_test.exs",
          context = "test",
        },
        {
          pattern = "/test/(.*)_test.exs$",
          target = "/lib/%1.ex",
          context = "source",
        },
        {
          pattern = "/app/(.*).php$",
          target = {
            { target = "/tests/%1Test.php", context = "test" },
            { target = "/test/%1Test.php", context = "test" },
          },
        },
        {
          pattern = "/tests/(.*)Test.php$",
          target = "/app/%1.php",
          context = "source",
        },
        {
          pattern = "/test/(.*)Test.php$",
          target = "/app/%1.php",
          context = "source",
        },
        {
          pattern = "/src/(.*).py$",
          target = "/tests/test_%1.py",
          context = "test",
        },
        {
          pattern = "/tests/test_(.*).py$",
          target = "/src/%1.py",
          context = "source",
        },
        {
          pattern = "/lib/(.*).js$",
          target = "/test/%1.test.js",
          context = "test",
        },
        {
          pattern = "/test/(.*).test.js$",
          target = "/lib/%1.js",
          context = "source",
        },
        {
          pattern = "/src/(.*).ts$",
          target = "/tests/%1.test.ts",
          context = "test",
        },
        {
          pattern = "/tests/(.*).test.ts$",
          target = "/src/%1.ts",
          context = "source",
        },
        {
          pattern = "/src/(.*).tsx$",
          target = "/tests/%1.test.tsx",
          context = "test",
        },
        {
          pattern = "/tests/(.*).test.tsx$",
          target = "/src/%1.tsx",
          context = "source",
        },
        {
          pattern = "/src/(.*).java$",
          target = "/src/test/java/%1Test.java",
          context = "test",
        },
        {
          pattern = "/src/test/java/(.*)Test.java$",
          target = "/src/main/java/%1.java",
          context = "source",
        },
        {
          pattern = "/lib/(.*).rs$",
          target = "/tests/%1_test.rs",
          context = "test",
        },
        {
          pattern = "/tests/(.*)_test.rs$",
          target = "/lib/%1.rs",
          context = "source",
        },
      },
      transformers = {
        lowercase = function(inputString)
          return inputString:lower()
        end,
        uppercase = function(inputString)
          return inputString:upper()
        end,
      },
      style = {
        border = "rounded",
        seperator = "|",
        width = 0.7,
        minHeight = 2,
      },
    })
  end,
}
