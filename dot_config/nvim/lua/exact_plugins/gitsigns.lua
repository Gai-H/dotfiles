local function setup_lazygit_diff(bufnr)
  if vim.g.lazygit_diff ~= 1 or bufnr ~= vim.fn.bufnr(vim.fn.argv(0)) then
    return
  end

  vim.g.lazygit_diff = nil

  local gitsigns = require("gitsigns")

  -- Keymap
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  map("n", "<leader>s", gitsigns.stage_hunk, "Stage hunk")
  map("n", "<leader>r", gitsigns.reset_hunk, "Reset hunk")

  map("x", "<leader>s", function()
    gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, "Stage selected lines")

  map("x", "<leader>r", function()
    gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, "Reset selected lines")

  -- The initial comparison data is loaded asynchronously after on_attach.
  vim.api.nvim_create_autocmd("User", {
    pattern = "GitSignsUpdate",
    desc = "Open the file edited from lazygit in Gitsigns diff mode",
    callback = function(event)
      -- Repository-wide HEAD updates also emit this event without data.
      if not event.data or event.data.buffer ~= bufnr then
        return
      end

      vim.schedule(function()
        if vim.api.nvim_get_current_buf() == bufnr then
          require("gitsigns").diffthis()
        end
      end)

      return true
    end,
  })
end

---@type LazyPluginSpec
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = "Gitsigns",
  opts = {
    on_attach = function(bufnr)
      setup_lazygit_diff(bufnr)
    end,
  },
}
