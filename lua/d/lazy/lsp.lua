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
            formatters_by_ft = {
            }
        })
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "jdtls",
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                rust_analyzer = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.rust_analyzer.setup({
                        root_dir = lspconfig.util.root_pattern(".git", "Cargo.toml"),
                        settings = {
                            ['rust-analyzer'] = {
                                server = { path = "~/.cargo/bin/rust_analyzer" },
                                files = {
                                    excludeDirs = { "target" }
                                },
                                workspace = {
                                    symbol = {
                                        search = {
                                            limit = 3000
                                        }
                                    }
                                },
                                procMacro = {
                                    enable = true
                                },
                                diagnosticics = {
                                    enable = true,
                                    disabled = { "unresolved-proc-macro" },
                                    enableExperiemental = true,
                                    refreshSupport = false,
                                },
                                check = {
                                    command = "clippy"
                                },
                                cargo = {
                                    features = "all",
                                    loadOutDirsFromCheck = true,
                                },
                            }
                        }
                    })
                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
                ["basedpyright"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.basedpyright.setup {
                        capabilities = capabilities,
                        settings = {
                            basedpyright = {
                                disableOrganizeImports = true,
                                analysis = {
                                    ignore = "*",
                                    typeCheckingMode = "standard",
                                    logLevel = "trace",
                                }
                            }
                        }
                    }
                end,
                ["ruff"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.ruff.setup {
                        init_options = {
                            settings = {

                                logLevel = "debug"
                            }
                        }
                    }
                end,
                ["jdtls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.jdtls.setup {
                        capabilities = capabilities,
                        settings = {
                            config = {
                                cmd = {
                                    -- 💀
                                    'java', -- or '/path/to/java21_or_newer/bin/java'
                                    -- depends on if `java` is in your $PATH env variable and if it points to the right version.

                                    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                                    '-Dosgi.bundles.defaultStartLevel=4',
                                    '-Declipse.product=org.eclipse.jdt.ls.core.product',
                                    '-Dlog.protocol=true',
                                    '-Dlog.level=ALL',
                                    '-Xmx1g',
                                    '--add-modules=ALL-SYSTEM',
                                    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
                                    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

                                    -- 💀
                                    '-jar', '/home/chilos/.local/share/nvim/mason/packages/jdtls/features/org.eclipse.equinox.executable_3.8.2800.v20241223-1657.jar',
                                    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
                                    -- Must point to the                                                     Change this to
                                    -- eclipse.jdt.ls installation                                           the actual version


                                    -- 💀
                                    '-configuration', '/home/chilos/.local/share/nvim/mason/packages/jdtls/config_linux',
                                    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
                                    -- Must point to the                      Change to one of `linux`, `win` or `mac`
                                    -- eclipse.jdt.ls installation            Depending on your system.


                                    -- 💀
                                    -- See `data directory configuration` section in the README
                                    '-data', '~/projects/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
                                },
                                root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
                                --root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" }),

                                -- Here you can configure eclipse.jdt.ls specific settings
                                -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                                -- for a list of options
                                settings = {
                                    java = {
                                    }
                                },

                                -- Language server `initializationOptions`
                                -- You need to extend the `bundles` with paths to jar files
                                -- if you want to use additional eclipse.jdt.ls plugins.
                                --
                                -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
                                --
                                -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
                                init_options = {
                                    bundles = {}
                                },
                            }
                            -- This starts a new client & server,
                            -- or attaches to an existing client & server depending on the `root_dir`.
                            --require('jdtls').start_or_attach(config)
                        }
                    }
                end,
            },
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
