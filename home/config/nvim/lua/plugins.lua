---- setting for neodev ----
-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({})
---- end ----

---- setting for lualine ----
require('lualine').setup {
    options = { icon_enabled = true, theme = 'tokyonight' },
}
---- end ----

---- setting for rainbow ----
vim.g.rainbow_active = 1
---- end ----

---- setting for colorscheme ----
vim.cmd('colorscheme tokyonight-night')
vim.cmd('highlight Normal ctermbg=none guibg=none')
vim.cmd('highlight NonText ctermbg=none guibg=none')
---- end ----

---- setting for window picker ----
require 'window-picker'.setup {
    include_current_win = true
}
---- end ----

---- setting for telescope ----
require('telescope').setup {
    defaults = {
        get_selection_window = require('window-picker').pick_window
    },
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<space>ff', builtin.find_files, {})
vim.keymap.set('n', '<space>fg', builtin.live_grep, {})
vim.keymap.set('n', '<space>fb', builtin.buffers, {})
vim.keymap.set('n', '<space>fh', builtin.help_tags, {})
---- end ----

---- setting for nvim-lspconfig ----
local lspconfig = require('lspconfig')

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<A-f>', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})
---- end ----

---- setting for nvim-cmp ----
-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- luasnip setup
local luasnip = require("luasnip")

-- Setup nvim-cmp.
local cmp = require('cmp')
cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
        ['<C-d>'] = cmp.mapping.scroll_docs(4),  -- Down
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
    },
}

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, { sources = { { name = 'buffer' } }, mapping = cmp.mapping.preset.cmdline() })

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } }),
    mapping = cmp.mapping.preset.cmdline(),
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = 'buffer' },
    })
})
---- end ----

---- config lsp server ----
-- pyright
lspconfig.pyright.setup {
    capabilities = capabilities,
}

-- lua language server
require 'lspconfig'.lua_ls.setup {
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
                Lua = {
                    runtime = {
                        version = 'LuaJIT'
                    },
                    -- Make the server aware of Neovim runtime files
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME
                        }
                    }
                }
            })

            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
        return true
    end,
    settings = {
    },
}
---- end ----

---- efm support ----
-- efm is used to lint and format for some lsps which do not support such functions
lspconfig.efm.setup {
    capabilities = capabilities,
    init_options = { documentFormatting = true },
    settings = {
        rootMarkers = { 'pyproject.toml', '.git' },
        languages = {
            python = {
                { formatCommand = 'black --quiet -', formatStdin = true },
            },
            sh = {
                { formatCommand = 'shfmt -s', formatStdin = true }
            }
        }
    },
    filetypes = { 'python', 'sh' },
    single_file_support = true
}
---- end ----

---- cmake ----
lspconfig.cmake.setup { capabilities = capabilities }

---- ccls ----
lspconfig.clangd.setup { capabilities = capabilities }
---- end ----

---- go ----
lspconfig.gopls.setup { capabilities = capabilities }
---- end ----

---- terraform ----
lspconfig.terraformls.setup { capabilities = capabilities }
---- end ----

--- rust-analyzer --
require 'lspconfig'.rust_analyzer.setup { capabilities = capabilities }
--- end ---

---- nix ----
require 'lspconfig'.nil_ls.setup {
    settings = {
        ['nil'] = {
            formatting = {
                command = { "nixpkgs-fmt" },
            },
        },
    },
}
--- end ----

require 'lspconfig'.bashls.setup {
    settings = {
        bashIde = {
            globPattern = "*@(.sh|.inc|.bash|.command)",
        },
    }
}
---- end for lsp server ----

---- nvim-tree setting ----
-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

require('nvim-tree').setup {
    sort_by = "case_sensitive",
    sync_root_with_cwd = true,
    view = {
        adaptive_size = true,
    },
    git = {
        enable = true,
        ignore = false
    },
    renderer = {
        indent_markers = {
            enable = true,
            icons = {
                corner = "└",
                edge = "│",
                item = "│",
                none = " "
            },
        },
        icons = {
            show = {
                folder_arrow = false,
            }
        }
    },
}
vim.keymap.set('n', '<A-d>', '<cmd>NvimTreeToggle<CR>',
    { silent = true, noremap = true })
---- end ----

---- toggleterm setting ----
require("toggleterm").setup {
    on_create = function(_)
        vim.cmd("DisableWhitespace")
    end
}
local Terminal = require('toggleterm.terminal').Terminal
local gitui    = Terminal:new({
    cmd = "gitui",
    hidden = true,
    direction = "float",
    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<A-g>", "<C-\\><C-n><cmd>lua Gitui_toggle()<CR>",
            { noremap = true, silent = true })
    end
})
local main     = Terminal:new({
    cmd = vim.o.shell,
    hidden = true,
    direction = "float",
    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<A-i>", "<C-\\><C-n><cmd>lua MainTerm_toggle()<CR>",
            { noremap = true, silent = true })
    end
})

function Gitui_toggle()
    gitui:toggle()
end

function MainTerm_toggle()
    main:toggle()
end

vim.api.nvim_set_keymap("n", "<A-g>", "<cmd>lua Gitui_toggle()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-i>", "<cmd>lua MainTerm_toggle()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-q>", "<C-\\><C-n>", { noremap = true, silent = true })
---- end ----

---- setting for gitsign ----
require('gitsigns').setup()
---- end ----

---- setting for treesitter ----
local parser_path = vim.fn.stdpath("data") .. "/parser"
vim.fn.mkdir(parser_path, "p")
vim.opt.runtimepath:append(parser_path)

require 'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all" (the four listed parsers should always be installed)
    ensure_installed = { "c", "lua", "vim", "help", "cmake", "python", "nix" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = false,

    ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
    parser_install_dir = parser_path, -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

    highlight = {
        enable = true,
        -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
        -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
        -- the name of the parser)
        -- list of language that will be disabled
        -- disable = { "c", "rust" },
        -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
        disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
}
---- end ----

---- setting for auto-session ----
local session_name = require('auto-session.lib').escaped_session_name_from_cwd()
local shadafile = vim.fn.stdpath('data') .. '/shada/' .. session_name .. '.shada'
local loadshada_cmd = ""
if vim.fn.filereadable(vim.fn.expand(shadafile)) == 1 then
    loadshada_cmd = "rshada! " .. shadafile
end
require("auto-session").setup {
    log_level = "error",

    cwd_change_handling = {
        post_cwd_changed_hook = function()
            require("lualine").refresh()
        end,
    },
    pre_restore_cmds = { "set shadafile=" .. shadafile, loadshada_cmd },
}
---- end ----

---- setting for nvim-dap ----
local dap = require("dap")
require("dapui").setup()
require("nvim-dap-virtual-text").setup()

vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F6>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F7>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F8>', function() require('dap').step_out() end)
vim.keymap.set('n', '<space>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<space>lp',
    function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<space>dr', function() require('dap').repl.open() end)
vim.keymap.set({ 'n', 'v' }, '<space>dp', function()
    require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<space>df', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<space>ds', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.scopes)
end)

vim.keymap.set('n', '<space>du', function()
    require("dapui").toggle()
end)


dap.adapters.delve_remote = {
    type = "server",
    port = 9004,
}

dap.configurations = {
    go = {
        {
            type = "delve_remote",
            name = "delve remote attach",
            request = "attach",
            mode = "remote",
            substitutepath = { {
                from = "${workspaceFolder}",
                to = "/workspace",
            } }
        }
    },
}
---- end ----
