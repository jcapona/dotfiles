-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim


-- General
lvim.log.level = "warn"
lvim.format_on_save = true


-- Themes
-- lvim.colorscheme = "onedarker"
-- require("rose-pine").setup({
--   variant = "moon",
-- })
-- lvim.colorscheme = "rose-pine"
lvim.colorscheme = "github_dark"


-- Keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"


-- Custom keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- Navigate buffers
lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"
-- Close buffer
lvim.keys.normal_mode["<S-w>"] = ":bd<CR>"


-- Additional Plugins
lvim.plugins = {
  -- {
  --   "folke/trouble.nvim",
  --   cmd = "TroubleToggle",
  -- },
  { "github/copilot.vim" },
  { "mg979/vim-visual-multi" },
  -- Themes:
  -- {"folke/tokyonight.nvim"},
  -- { "rose-pine/neovim" },
  { "projekt0n/github-nvim-theme" },
}

-- Formatting & Linters
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { name = "black" },
  {
    name = "prettier",
    ---@usage arguments to pass to the formatter
    -- these cannot contain whitespace
    -- options such as `--line-width 80` become either `{"--line-width", "80"}` or `{"--line-width=80"}`
    args = { "--print-width", "100" },
    ---@usage only start in these filetypes, by default it will attach to all filetypes it supports
    filetypes = { "typescript", "typescriptreact" },
  },
}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { name = "flake8" },
  {
    name = "shellcheck",
    args = { "--severity", "warning" },
  },
}

local code_actions = require "lvim.lsp.null-ls.code_actions"
code_actions.setup {
  {
    name = "proselint",
  },
}
