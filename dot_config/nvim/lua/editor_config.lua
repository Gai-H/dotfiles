local opt = vim.opt

-- 全角文字が半角文字と重ならないようにする
-- opt.ambiwidth = "double"

-- カーソルが存在する行にハイライトをあてる
opt.cursorline = true

-- インデント
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- 行番号
opt.number = true
opt.relativenumber = true
opt.wrap = true
opt.termguicolors = true

-- エンコーディング
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- クリップボード
opt.clipboard:append("unnamedplus")

-- コマンドライン
opt.wildmenu = true
opt.laststatus = 2
opt.showcmd = true

-- 検索・置換
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.showmatch = true
opt.matchtime = 1

-- カラースキーム
opt.termguicolors = true
opt.background = "dark"

-- netrw の無効化
local g = vim.g
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- yl, dl, cl, >l, <l などの追加
--- vim.keymap.set("o", "l", function()
---   local n = vim.v.count1
---   return (n > 1 and tostring(n) or "") .. "V"
--- end, { expr = true, silent = true, desc = "Use l as line text-object in operator-pending" })

-- escape from terminal mode
vim.keymap.set('t', 'fj', "<C-`\\><C-n>", { noremap = true, silent = true })

-- buffer navigation
vim.keymap.set("n", "<M-j>", "<cmd>bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<M-k>", "<cmd>bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<M-w>", "<cmd>bdelete<CR>", { noremap = true, silent = true, desc = "Delete buffer" })
vim.keymap.set("n", "<M-t>", "<cmd>enew<CR>", { noremap = true, silent = true, desc = "New buffer" })

-- exrc
vim.o.exrc = true
