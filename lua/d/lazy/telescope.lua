return {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },

    config = function()
        local function telescope_colors()
            local transparent = { bg = "none" }

            vim.api.nvim_set_hl(0, "TelescopePromptNormal", transparent)
            vim.api.nvim_set_hl(0, "TelescopeResultsNormal", transparent)
            vim.api.nvim_set_hl(0, "TelescopePreviewNormal", transparent)
            vim.api.nvim_set_hl(0, "TelescopeNormal", transparent)

            vim.api.nvim_set_hl(0, "TelescopePromptBorder", transparent)
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", transparent)
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", transparent)
            vim.api.nvim_set_hl(0, "TelescopeBorder", transparent)

            vim.api.nvim_set_hl(0, "TelescopePromptTitle", transparent)
            vim.api.nvim_set_hl(0, "TelescopeResultsTitle", transparent)
            vim.api.nvim_set_hl(0, "TelescopePreviewTitle", transparent)

            vim.api.nvim_set_hl(0, "TelescopeSelection", { link = "Visual" })
            vim.api.nvim_set_hl(0, "TelescopeMatching", { link = "Search" })
        end

        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = function()
                vim.schedule(telescope_colors)
            end,
        })

        vim.schedule(telescope_colors)

        vim.schedule(telescope_colors)
        require("telescope").setup({
            defaults = {
                winblend = 0, -- transparency can make colors look wrong
            },
        })
        --require('telescope').setup({})

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
    end
}
