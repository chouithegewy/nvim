return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                panel = {
                    enabled = false,
                },
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    hide_during_completion = true,
                    debounce = 75,
                    keymap = {
                        accept = false, -- Handled by custom keymap below for tab fallback
                        accept_word = false,
                        accept_line = false,
                        next = "<M-]>",
                        prev = "<M-[>",
                        dismiss = "<C-]>",
                    },
                },
            })

            -- Set up custom <Tab> fallback mapping:
            -- If Copilot suggestion is visible, accept it. Otherwise, perform a normal Tab.
            vim.keymap.set("i", "<Tab>", function()
                local suggestion = require("copilot.suggestion")
                if suggestion.is_visible() then
                    suggestion.accept()
                else
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", true)
                end
            end, { desc = "Copilot - Accept suggestion or Tab" })
        end,
    },
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "zbirenbaum/copilot.lua",
        },
        config = function()
            require("codecompanion").setup({
                opts = {
                    log_level = "DEBUG",
                },
                strategies = {
                    chat = {
                        adapter = "copilot",
                    },
                    inline = {
                        adapter = "copilot",
                    },
                },
                adapters = {
                    http = {
                        copilot = function()
                            return require("codecompanion.adapters").extend("copilot", {
                                schema = {
                                    model = {
                                        default = "gpt-5.5",
                                    },
                                },
                            })
                        end,
                    },
                },
            })

            -- Keymaps for CodeCompanion:
            -- Toggle chat window
            vim.keymap.set({ "n", "v" }, "<leader>cct", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "CodeCompanion - Toggle Chat" })

            -- Open actions menu (Action Palette)
            vim.keymap.set({ "n", "v" }, "<leader>cca", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion - Actions" })

            -- Inline assistant
            vim.keymap.set({ "n", "v" }, "<leader>cci", "<cmd>CodeCompanion<cr>", { desc = "CodeCompanion - Inline Assistant" })
        end,
    }
}
