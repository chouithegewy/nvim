return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    cmd = "RenderMarkdown",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {},
    keys = {
        { "<leader>rm", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle Markdown rendering" },
    },
}
