-- disable netrw for neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.guicursor = ""

vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "120"

vim.opt.clipboard:append { 'unnamed', 'unnamedplus' }

-- Clipboard over SSH/mosh. On a headless remote both xclip and xsel are usually
-- installed but $DISPLAY is empty, so Neovim's auto-detected provider copies
-- into a dead X server and the yank silently vanishes. Force the terminal's
-- OSC 52 escape instead: tmux (set-clipboard on) and mosh relay it all the way
-- back to the local terminal's clipboard. Guarded on $SSH_TTY + no display so
-- the laptop keeps its native provider.
local function empty(v) return v == nil or v == '' end
if vim.env.SSH_TTY and empty(vim.env.DISPLAY) and empty(vim.env.WAYLAND_DISPLAY) then
  local osc52 = require('vim.ui.clipboard.osc52')
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
    paste = { ['+'] = osc52.paste('+'), ['*'] = osc52.paste('*') },
  }
end

vim.opt.foldenable = false
