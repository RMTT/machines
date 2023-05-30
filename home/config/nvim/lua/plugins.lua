---- setting for neodev ----
-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({
})
---- end ----
--
---- setting for lualine ----
require('lualine').setup {
    options = { icon_enabled = true, theme = 'tokyonight' },
    sections = { lualine_c = { require('auto-session.lib').current_session_name } } }
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
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<A-f>', function() vim.lsp.buf.format { async = true } end, bufopts)
end
---- end ----

---- setting for nvim-cmp ----
vim.o.completeopt = 'menu,menuone,noselect'

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

-- Setup nvim-cmp.
local cmp = require('cmp')

local mappings = {
    ['<C-n>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        elseif has_words_before() then
            cmp.complete()
        else
            fallback()
        end
    end, { "i", "s" }),
    ['<C-p>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
        else
            fallback()
        end
    end, { "i", "s" }),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
}
cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end
    },
    mapping = mappings,
    sources = cmp.config.sources({
        { name = 'nvim_lsp' }, { name = 'luasnip' }
    }, { { name = 'buffer' } })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', { sources = { { name = 'buffer' } }, mapping = cmp.mapping.preset.cmdline() })

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } }),
    mapping = cmp.mapping.preset.cmdline(),
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = 'buffer' },
    })
})
---- end ----

---- config lsp server ----
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- pyright
lspconfig.pyright.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

-- lua language server
require 'lspconfig'.lua_ls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
            format = {
                enable = true
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

---- efm support ----
-- efm is used to lint and format for some lsps which do not support such functions
lspconfig.efm.setup {
    init_options = { documentFormatting = true },
    settings = {
        rootMarkers = { 'pyproject.toml', '.git' },
        languages = {
            python = {
                { formatCommand = 'yapf', formatStdin = true },
            }
        }
    },
    filetypes = { 'python', }
}
---- end ----

---- cmake ----
lspconfig.cmake.setup { on_attach = on_attach, capabilities = capabilities }

---- ccls ----
lspconfig.clangd.setup { on_attach = on_attach, capabilities = capabilities }
---- end ----

---- go ----
lspconfig.gopls.setup { on_attach = on_attach, capabilities = capabilities }
---- end ----

---- terraform ----
lspconfig.terraformls.setup { on_attach = on_attach, capabilities = capabilities }
---- end ----

--- rust-analyzer --
require 'lspconfig'.rust_analyzer.setup { on_attach = on_attach, capabilities = capabilities }
--- end ---

---- nix ----
require 'lspconfig'.nil_ls.setup {}
--- end ----

---- end for lsp server ----

---- lua-tree setting ----
-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

local function nvim_tree_on_attach(bufnr)
    local api = require('nvim-tree.api')

    local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(bufnr)

    vim.keymap.set('n', 'O', '', { buffer = bufnr })
    vim.keymap.del('n', 'O', { buffer = bufnr })
    vim.keymap.set('n', '<2-RightMouse>', '', { buffer = bufnr })
    vim.keymap.del('n', '<2-RightMouse>', { buffer = bufnr })
    vim.keymap.set('n', 'D', '', { buffer = bufnr })
    vim.keymap.del('n', 'D', { buffer = bufnr })
    vim.keymap.set('n', 'E', '', { buffer = bufnr })
    vim.keymap.del('n', 'E', { buffer = bufnr })

    vim.keymap.set('n', 'A', api.tree.expand_all, opts('Expand All'))
    vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
    vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts('CD'))
    vim.keymap.set('n', 'P', function()
        local node = api.tree.get_node_under_cursor()
        print(node.absolute_path)
    end, opts('Print Node Path'))

    vim.keymap.set('n', 'Z', api.node.run.system, opts('Run System'))
end

require('nvim-tree').setup {
    on_attach = nvim_tree_on_attach,
    sort_by = "case_sensitive",
    sync_root_with_cwd = true,
    view = {
        adaptive_size = true,
        mappings = {
            list = {
                { key = "u", action = "dir_up" },
            },
        },
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

---- FTerm setting ----
local fterm = require 'FTerm'
fterm.setup({ border = 'single', dimensions = { height = 0.9, width = 0.9 } })
vim.api.nvim_set_keymap('n', '<A-i>', '<CMD>lua require("FTerm").toggle()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<A-i>',
    '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>',
    { noremap = true, silent = true })
local gitui = fterm:new({
    ft = 'fterm_gitui',
    cmd = "gitui",
    dimensions = { height = 0.9, width = 0.9 }
})

-- Use this to toggle gitui in a floating terminal
function _G.__fterm_gitui() gitui:toggle() end

vim.api.nvim_set_keymap('n', '<A-g>', '<cmd>lua __fterm_gitui()<CR>',
    { silent = true, noremap = true })

local top = fterm:new({
    ft = 'fterm_top',
    cmd = "btop",
    dimensions = { height = 0.9, width = 0.9 }
})
-- Use this to toggle btop in a floating terminal
function _G.__fterm_top() top:toggle() end

vim.api.nvim_set_keymap('n', '<A-t>', '<cmd>lua __fterm_top()<CR>',
    { silent = true, noremap = true })
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

    -- List of parsers to ignore installing (for "all")
    ignore_install = { "make" },

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
require("auto-session").setup {
    log_level = "error",

    cwd_change_handling = {
        post_cwd_changed_hook = function()
            require("lualine").refresh()
        end,
    },
}
---- end ----
