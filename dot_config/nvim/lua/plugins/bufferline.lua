---@type LazyPluginSpec
return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons"
  },
  config = function()
    vim.opt.termguicolors = true

    local bufferline = require("bufferline")
    bufferline.setup {
      options = {
        right_mouse_command = false,
        middle_mouse_command = "bdelete! %d",
        indicator = {
          style = "underline"
        },
        always_show_bufferline = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = {"close"}
        },
        show_close_icon = false,
        show_buffer_close_icons = false
      }
    }
  end
}

