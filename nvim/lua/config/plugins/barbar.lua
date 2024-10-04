-- https://github.com/romgrk/barbar.nvim
return {'romgrk/barbar.nvim',
    dependencies = {
        'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
        'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {},
    version = '^1.0.0',
    config = function()
        require('barbar').setup({})
        local opts = { noremap = true, silent = true }
        vim.keymap.set('n', '<S-w>', '<Cmd>BufferClose<CR>', opts)
        vim.keymap.set('n', '<S-h>', '<Cmd>BufferPrevious<CR>', opts)
        vim.keymap.set('n', '<S-l>', '<Cmd>BufferNext<CR>', opts)
    end
}
