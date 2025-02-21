-- lua/plugins/img-clip.lua

local status_ok, img_clip = pcall(require, "img-clip")
if not status_ok then
  return
end

img_clip.setup({
  filetypes = {
    markdown = {
      url_encode_path = true,
      template = "![$CURSOR]($FILE_PATH)"
    }
  }
})
