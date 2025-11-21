return {
  "mistweaverco/kulala.nvim",
  ft = "http",
  config = function()
    require("kulala").setup({
    default_view = "body",
    default_env = "dev",
    debug = false,
    contenttypes = {
      json = {
        ft = "json",
        formatter = { "jq", "." },
        pathresolver = { "jq", "-r" },
      },
      xml = {
        ft = "xml",
        formatter = { "xmllint", "--format", "-" },
        pathresolver = {},
      },
      html = {
        ft = "html",
        formatter = { "xmllint", "--format", "--html", "-" },
        pathresolver = {},
      },
    },
      show_icons = "off",
      additional_curl_options = {},
      winbar = false,
    })

    local http_dir = "/home/jose/GoogleDrive/GDRIVE_NVIM_RESOURCES/HTTP_REQUESTS"

    vim.api.nvim_create_user_command("HttpNew", function(opts)
      local filename = opts.args ~= "" and opts.args or "request.http"
      if not filename:match("%.http$") then
        filename = filename .. ".http"
      end
      local filepath = http_dir .. "/" .. filename
      vim.cmd("edit " .. filepath)
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("HttpList", function()
      require("telescope.builtin").find_files({
        prompt_title = "HTTP Requests",
        cwd = http_dir,
        search_dirs = { http_dir },
        find_command = { "rg", "--files", "--glob", "*.http" },
      })
    end, {})
  end,
  keys = {
    { "<leader>ra", "<cmd>lua require('kulala').run_all()<cr>", desc = "Run all requests" },
    { "<leader>rs", "<cmd>lua require('kulala').run()<cr>", desc = "Send request" },
    { "<leader>rt", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "Toggle view" },
    { "<leader>rp", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request" },
    { "<leader>rn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request" },
    { "<leader>re", "<cmd>lua require('kulala').set_selected_env()<cr>", desc = "Select environment" },
    { "<leader>rc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy request as cURL" },
    { "<leader>ri", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect request" },
    { "<leader>rq", "<cmd>lua require('kulala').close()<cr>", desc = "Close result window" },
    { "<leader>rh", "<cmd>HttpNew<cr>", desc = "Create new HTTP file" },
    { "<leader>rl", "<cmd>HttpList<cr>", desc = "List HTTP files" },
    { "<leader>ra", "<cmd>lua require('kulala').run_all()<cr>", desc = "Run all requests" },
  },
}
