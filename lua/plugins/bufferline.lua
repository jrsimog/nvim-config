-- lua/plugins/bufferline.lua

local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  return
end

bufferline.setup({
  options = {
    separator_style = "thin"
  }
})
