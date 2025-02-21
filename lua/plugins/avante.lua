-- lua/plugins/avante.lua

local function setup_plugin(name, config)
  local status_ok, plugin = pcall(require, name)
  if status_ok then
    plugin.setup(config or {})
  else
    vim.notify('Plugin ' .. name .. ' no encontrado', vim.log.levels.WARN)
  end
end

setup_plugin('avante', {
  provider = "gemini",
  vendors = {
    gemini = {
      __inherited_from = "openai",
      api_key_name = "GEMINI_API_KEY",
      endpoint = "https://api.gemini.com/v1",
      model = "gemini-coder-33b-instruct",
    },
  },
  behaviour = {
    auto_suggestions = true,
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = false,
    minimize_diff = true,
  },
  mappings = {
    diff = {
      ours = "co",
      theirs = "ct",
      all_theirs = "ca",
      both = "cb",
      cursor = "cc",
      next = "]x",
      prev = "[x",
    },
    suggestion = {
      accept = "<M-l>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
    submit = {
      normal = "<CR>",
      insert = "<C-s>",
    },
  },
  windows = {
    position = "right",
    wrap = true,
    width = 30,
    sidebar_header = {
      enabled = true,
      align = "center",
      rounded = true,
    },
  },
})
