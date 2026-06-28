---@type LazyPluginSpec
return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "1.*",
  opts = {
    keymap = {
      preset = "default",
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
    completion = {
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
    },
    sources = {
      default = { "lsp", "path", "buffer" },
    },
  },
}
