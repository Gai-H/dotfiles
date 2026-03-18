---@type LazyPluginSpec
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "saghen/blink.cmp",
  },
  config = function()
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    local servers = require("lsp")

    local function on_attach(_, bufnr)
      local keymap = vim.keymap.set
      local opts = { buffer = bufnr, silent = true }

      keymap("n", "gk", vim.lsp.buf.hover, opts)
      keymap("n", "grn", vim.lsp.buf.rename, opts)
      keymap({ "n", "x" }, "ga", vim.lsp.buf.code_action, opts)
      keymap("n", "gdf", vim.lsp.buf.definition, opts)
      keymap("n", "grf", vim.lsp.buf.references, opts)
    end

    vim.lsp.config("*", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    for server_name, server_opts in pairs(servers) do
      vim.lsp.config(server_name, server_opts)
    end
  end,
}
