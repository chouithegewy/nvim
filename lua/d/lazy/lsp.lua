return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        require("conform").setup({
            formatters_by_ft = {},
        })

        local cmp = require("cmp")
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )

        local tsgo_warned_roots = {}

        local function warn_missing_node_modules(client)
            local root_dir = client.root_dir
            if not root_dir or tsgo_warned_roots[root_dir] then
                return
            end

            if vim.fn.filereadable(root_dir .. "/package.json") == 0 then
                return
            end

            if vim.fn.isdirectory(root_dir .. "/node_modules") == 1 then
                return
            end

            tsgo_warned_roots[root_dir] = true
            vim.schedule(function()
                vim.notify(
                    ("tsgo: no node_modules found in %s. Install frontend dependencies on the host if you want accurate React/Vite diagnostics."):format(root_dir),
                    vim.log.levels.WARN
                )
            end)
        end

        local function ts_code_action(action_kinds)
            return function()
                vim.lsp.buf.code_action({
                    apply = true,
                    context = {
                        only = action_kinds,
                    },
                })
            end
        end

        local function on_tsgo_attach(client, bufnr)
            warn_missing_node_modules(client)

            local opts = { buffer = bufnr, silent = true }
            vim.keymap.set(
                "n",
                "<leader>co",
                ts_code_action({ "source.organizeImports.ts", "source.organizeImports" }),
                vim.tbl_extend("force", opts, { desc = "Organize imports" })
            )
            vim.keymap.set(
                "n",
                "<leader>cM",
                ts_code_action({ "source.addMissingImports.ts" }),
                vim.tbl_extend("force", opts, { desc = "Add missing imports" })
            )
            vim.keymap.set(
                "n",
                "<leader>cu",
                ts_code_action({ "source.removeUnused.ts" }),
                vim.tbl_extend("force", opts, { desc = "Remove unused imports" })
            )

            if client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
        end

        require("fidget").setup({})
        require("mason").setup()

        vim.lsp.config("lua_ls", {
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = {
                        globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                    },
                    workspace = {
                        checkThirdParty = false,
                    },
                },
            },
        })

        vim.lsp.config("rust_analyzer", {
            capabilities = capabilities,
            settings = {
                ["rust-analyzer"] = {
                    files = {
                        excludeDirs = { "target" },
                    },
                    workspace = {
                        symbol = {
                            search = {
                                limit = 3000,
                            },
                        },
                    },
                    procMacro = {
                        enable = true,
                    },
                    diagnostics = {
                        disabled = { "unresolved-proc-macro" },
                    },
                    check = {
                        command = "clippy",
                    },
                    cargo = {
                        features = "all",
                        loadOutDirsFromCheck = true,
                    },
                },
            },
        })

        vim.lsp.config("tsgo", {
            capabilities = capabilities,
            single_file_support = false,
            on_attach = on_tsgo_attach,
            settings = {
                typescript = {
                    suggest = {
                        completeFunctionCalls = true,
                    },
                    updateImportsOnFileMove = {
                        enabled = "always",
                    },
                    inlayHints = {
                        parameterNames = {
                            enabled = "literals",
                            suppressWhenArgumentMatchesName = true,
                        },
                        parameterTypes = { enabled = true },
                        variableTypes = { enabled = true },
                        propertyDeclarationTypes = { enabled = true },
                        functionLikeReturnTypes = { enabled = true },
                        enumMemberValues = { enabled = true },
                    },
                },
                javascript = {
                    suggest = {
                        completeFunctionCalls = true,
                    },
                    updateImportsOnFileMove = {
                        enabled = "always",
                    },
                    inlayHints = {
                        parameterNames = {
                            enabled = "literals",
                            suppressWhenArgumentMatchesName = true,
                        },
                        parameterTypes = { enabled = true },
                        variableTypes = { enabled = true },
                        propertyDeclarationTypes = { enabled = true },
                        functionLikeReturnTypes = { enabled = true },
                        enumMemberValues = { enabled = true },
                    },
                },
            },
        })

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "jdtls",
                "tsgo",
            },
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
            }, {
                { name = "buffer" },
            }),
        })

        vim.diagnostic.config({
            severity_sort = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end,
}
