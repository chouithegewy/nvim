return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            ensure_installed = {
                "vimdoc",
                "lua",
                "rust",
                "bash",
                "javascript",
                "typescript",
                "tsx",
                "html",
                "css",
                "json",
                "jsonc",
            },

            ignore_installed = { "xml" },
            sync_install = false,
            auto_install = true,

            indent = {
                enable = true,
            },

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
                disable = function(lang, buf)
                    local max_filesize = 100 * 1024
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                end,
            },
        })
    end,
}
