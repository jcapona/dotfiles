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

-- Clipboard over SSH/mosh: send yanks to the laptop via OSC 52, even when the
-- remote has a $DISPLAY (xclip would fill the remote desktop's clipboard).
-- Both registers copy as `c`: mosh drops the `p` selection. Paste returns the
-- last yank, because mosh never answers an OSC 52 read and `p` would block ~10s;
-- paste laptop text with Cmd+V.
if vim.env.SSH_TTY then
  local osc52 = require('vim.ui.clipboard.osc52')
  local copy_to_laptop = osc52.copy('+')
  local last_yank = { {}, 'v' }
  local function copy(lines, regtype)
    last_yank = { lines, regtype }
    copy_to_laptop(lines)
  end
  local function paste() return last_yank end
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = { ['+'] = copy, ['*'] = copy },
    paste = { ['+'] = paste, ['*'] = paste },
  }
end

vim.opt.foldenable = false
