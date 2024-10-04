-- https://github.com/zbirenbaum/copilot.lua
-- https://github.com/zbirenbaum/copilot-cmp
-- Also, linked copilot to nvim-cmp for auto-completion, check lsp.lua
return {
    {
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        event = 'InsertEnter',
        config = function()
            require "copilot".setup({
                suggestion = { enabled = false },
                panel = { enabled = false },
            })
        end
    },
    {
        'zbirenbaum/copilot-cmp',
        config = function()
            require("copilot_cmp").setup()
        end,
    },
}
