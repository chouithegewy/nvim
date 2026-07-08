return {
    "jmbuhr/otter.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("otter").setup({
            lsp = {
                diagnostic_update_events = { "BufWritePost", "InsertLeave" },
            },
            buffers = {
                set_filetype = true,
            },
        })

        local group = vim.api.nvim_create_augroup("d-otter", { clear = true })

        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = { "html" },
            callback = function()
                require("otter").activate()
            end,
        })

        -- otter-ls mutates request params in place; nvim 0.12's staleness
        -- check (ctx_is_valid in vim.lsp.buf) then sees a position that no
        -- longer matches the cursor and silently drops hover/definition
        -- responses. Hand otter a deep copy so the original stays intact.
        vim.api.nvim_create_autocmd("LspAttach", {
            group = group,
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if not client or not client.name:match("^otter%-ls") then
                    return
                end
                local rpc = client.rpc
                if rpc._otter_params_copy then
                    return
                end
                rpc._otter_params_copy = true
                local orig_request = rpc.request
                rpc.request = function(method, params, handler, ...)
                    return orig_request(method, params and vim.deepcopy(params) or params, handler, ...)
                end
            end,
        })
    end,
}
