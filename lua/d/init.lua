require("d.set")
require("d.remap")
require("d.lazy_init")

local augroup = vim.api.nvim_create_augroup
local ChilosGroup = augroup('TheChilos', {})
local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})
function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})
autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})
autocmd({ "BufWritePre" }, {
    group = ChilosGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})
autocmd('LspAttach', {
    group = ChilosGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function()
            -- C library documentation lives in man pages; clangd omits macro comments.
            local filetype = vim.bo.filetype
            local word = vim.fn.expand("<cword>")
            if (filetype == "c" or filetype == "cpp")
                and word:match("^[%a_][%w_]*$")
                and vim.fn.executable("man") == 1 then
                for _, section in ipairs({ "3", "2" }) do
                    local page = vim.system({ "man", "-w", section, word }, { timeout = 1000 }):wait()
                    if page.code == 0 and page.stdout:match("%S") then
                        vim.cmd.Man({ section, word, mods = { vertical = true } })
                        -- Shared pages (e.g. fpclassify) describe several symbols.
                        if vim.fn.search("^DESCRIPTION\\s*$", "cw") > 0 then
                            vim.fn.search("\\C\\%(^\\|\\W\\)\\zs" .. word .. "\\s*(", "W")
                            vim.cmd("normal! zz")
                        end
                        return
                    end
                end
            end

            vim.lsp.buf.hover()
        end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.g.python3_host_prog = "./home/d/.pyenv/versions/neovim/bin/python"
vim.g.python_host_prog = "./home/d/.pyenv/versions/neovim/bin/python"
