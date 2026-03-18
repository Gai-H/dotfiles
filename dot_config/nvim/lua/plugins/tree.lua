---@type LazyPluginSpec
return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = function()
    local HEIGHT_RATIO = 0.8
    local WIDTH_RATIO  = 0.5

    local api     = require("nvim-tree.api")
    local opt     = vim.opt
    local keymap  = vim.keymap

    local function map(bufnr, lhs, rhs, desc)
      keymap.set("n", lhs, rhs, {
        desc = "nvim-tree: " .. desc,
        buffer = bufnr,
        noremap = true,
        silent = true,
        nowait = true,
      })
    end

    local function make_centered_float()
      local screen_w = opt.columns:get()
      local screen_h = opt.lines:get() - opt.cmdheight:get()

      local win_w = math.floor(screen_w * WIDTH_RATIO)
      local win_h = math.floor(screen_h * HEIGHT_RATIO)

      local row = math.floor((screen_h - win_h) / 2)
      local col = math.floor((screen_w - win_w) / 2)

      return {
        border   = "single",
        relative = "editor",
        row      = row,
        col      = col,
        width    = win_w,
        height   = win_h,
      }
    end

    return {
      on_attach = function(bufnr)
        -- disable default keybinds
        -- api.config.mappings.default_on_attach(bufnr)

        map(bufnr, "h", function()
          local node = api.tree.get_node_under_cursor()
          if not node then return end
          local is_root = (node.parent == nil)
          if is_root then
            api.tree.change_root_to_parent()
          else
            api.node.navigate.parent_close()
          end
        end, "close_or_change_root_to_parent")

        map(bufnr, "l", function()
          local node = api.tree.get_node_under_cursor()
          if not node then return end
          if node.type == "directory" and not node.open then
            api.node.open.edit(node)
          end
        end, "expand_folder")

        map(bufnr, "a", api.fs.create,          "create")
        map(bufnr, "R", api.fs.rename_full,     "rename_full")
        map(bufnr, "r", api.fs.rename_basename, "rename_basename")
        map(bufnr, "<CR>", api.node.open.edit,  "open")
        map(bufnr, "<Tab>", api.node.open.preview, "preview")
        map(bufnr, "c", api.fs.copy.node,       "copy")
        map(bufnr, "p", api.fs.paste,           "paste")
        map(bufnr, "x", api.fs.cut,             "cut")
        map(bufnr, "d", api.fs.remove,          "delete")
      end,

      view = {
        float = {
          enable = true,
          open_win_config = make_centered_float,
        },
        width = function()
          return math.floor(opt.columns:get() * WIDTH_RATIO)
        end,
      },
    }
  end,
  config = function(_, opts)
    local tree = require("nvim-tree")
    local api  = require("nvim-tree.api")

    tree.setup(opts)

    local group_id = vim.api.nvim_create_augroup("NvimTreeResize", { clear = true })
    vim.api.nvim_create_autocmd("VimResized", {
      group = group_id,
      callback = function()
        if api.tree.is_visible() then
          api.close()
          tree.open()
        end
      end,
    })

    vim.api.nvim_create_user_command("Tree", function()
      if api.tree.is_visible() then
        return
      end
      local current_buf = vim.api.nvim_get_current_buf()
      api.tree.open({ path = vim.fn.getcwd() })
      api.tree.collapse_all()
      api.tree.find_file({
        buf = current_buf,
        open = true,
        focus = true,
      })
    end, {})

    -- vim.keymap.set("n", "e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
  end,
}
