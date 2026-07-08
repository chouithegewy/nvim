return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
        -- The "main" branch is a full rewrite: setup() no longer takes
        -- ensure_installed/highlight/indent, so parsers must be installed
        -- explicitly and highlight/indent enabled per-buffer via autocmd.
        -- https://github.com/nvim-treesitter/nvim-treesitter#readme
        local ensure_installed = {
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
        }

        require("nvim-treesitter").install(ensure_installed)

        local max_filesize = 100 * 1024

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("d-treesitter", { clear = true }),
            callback = function(args)
                local bufnr = args.buf
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
                if ok and stats and stats.size > max_filesize then
                    return
                end

                if not pcall(vim.treesitter.start, bufnr) then
                    return
                end

                vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
