-- https://github.com/lewis6991/gitsigns.nvim
return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        on_attach = function(bufnr)
            local gs = require("gitsigns")
            vim.keymap.set("n", "<leader>gb", gs.blame_line, { buffer = bufnr, desc = "Git blame line" })
        end,
    },
}
