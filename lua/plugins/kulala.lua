return {
  "mistweaverco/kulala.nvim",
  ft = "http",
  config = function()
    require("kulala").setup({
    default_view = "body",
    default_env = "dev",
    debug = false,
    treesitter = true,
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
      ui = {
        max_response_size = 10485760,
      },
    })

    local http_dir = "/home/jose/GDRIVE_NVIM_RESOURCES/HTTP_REQUESTS"

    vim.api.nvim_create_user_command("HttpNew", function(opts)
      local filename = opts.args ~= "" and opts.args or "request.http"
      if not filename:match("%.http$") then
        filename = filename .. ".http"
      end
      local filepath = http_dir .. "/" .. filename
      vim.cmd("edit " .. filepath)
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("HttpList", function()
      local files = vim.fn.glob(http_dir .. "/*.http", false, true)
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      pickers.new({}, {
        prompt_title = "HTTP Requests",
        previewer = conf.file_previewer({}),
        finder = finders.new_table({
          results = files,
          entry_maker = function(file)
            local filename = vim.fn.fnamemodify(file, ":t")
            local icon, icon_hl = require("nvim-web-devicons").get_icon(filename, "http", { default = true })
            return {
              value = file,
              path = file,
              display = function()
                local displayer = require("telescope.pickers.entry_display").create({
                  separator = " ",
                  items = { { width = 2 }, { remaining = true } },
                })
                return displayer({ { icon, icon_hl }, filename })
              end,
              ordinal = filename,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            vim.cmd("edit " .. vim.fn.fnameescape(selection.value))
          end)
          return true
        end,
      }):find()
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
