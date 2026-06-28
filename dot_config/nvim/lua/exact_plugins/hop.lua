---@type LazyPluginSpec
return {
  "smoka7/hop.nvim",
  version = "*",
  config = function()
    require("hop").setup()
    vim.api.nvim_set_keymap("n", "f", "<cmd>HopWord<CR>", { noremap = true, silent = true })
  end
}

