vim.g.mapleader = ','
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4 -- tab -> spaces
vim.opt.tabstop = 4 -- tab -> spaces visually
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.grepprg = 'rg --vimgrep'
vim.opt.backup = true
vim.opt.backupdir = os.getenv('HOME') .. '/.cache/nvim/backup//'
vim.opt.directory = os.getenv('HOME') .. '/.cache/nvim/swap//'
vim.opt.undofile = true
vim.opt.undodir = os.getenv('HOME') .. '/.cache/nvim/undo//'
vim.opt.updatetime = 100
vim.opt.timeoutlen = 300
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.clipboard = "unnamedplus" -- necessary for tmux cp buffer mirror
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
-- vim.opt.termguicolors = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- clear highlight of search
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local stl = {
    '%#StatusLine#%2f',          -- buffer number
    ' ',                          -- separator
    '%<',                         -- truncate here
    '%*»',                        -- separator
    '%*»',                        -- separator
    '%#DiffText#%m',              -- modified flag
    '%r',                         -- readonly flag
    '%*»',                        -- separator
    '%#CursorLine#(%l/%L,%c)%*»', -- line no./no. of lines,col no.
    '%=«',                        -- right align the rest
    --  '%#Cursor#%02B',              -- value of current char in hex
    --  '%*«',                        -- separator
    --  '%#ErrorMsg#%o',              -- byte offset
    --  '%*«',                        -- separator
    '%#Title#%y',                 -- filetype
    '%*«',                        -- separator
    '%#ModeMsg#%3p%%',            -- % through file in lines
    '%*',                         -- restore normal highlight
}
vim.opt.statusline = table.concat(stl)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        -- Color
        {
            'projekt0n/github-nvim-theme',
            name = 'github-theme',
            lazy = false, -- make sure we load this during startup if it is your main colorscheme
            priority = 1000, -- make sure to load this before all the other start plugins
            config = function()
                require('github-theme').setup({
                    -- ...
                })

                vim.cmd('colorscheme github_light')
            end,
        },
        {'dracula/vim'},
        -- Finder
        { "junegunn/fzf", build = function() vim.fn["fzf#install"]() end , cmd = "FZF"},
        -- { "junegunn/fzf.vim"},
        {
            "ibhagwan/fzf-lua",
            cmd = "FzfLua",
            -- optional for icon support
            -- dependencies = { "nvim-tree/nvim-web-devicons" },
            -- or if using mini.icons/mini.nvim
            -- dependencies = { "echasnovski/mini.icons" },
            opts = {}
        },
        -- Tmux
        { "christoomey/vim-tmux-navigator", event = "VeryLazy"}, -- Seamless navigation between Neovim & tmux
        -- Motion
        { "smoka7/hop.nvim", opts = {keys = 'etovxqpdygfblzhckisuran'}},
        -- Misc
        { "t9md/vim-quickhl"},
        -- Commneter
        { "numToStr/Comment.nvim", config = function()
            require("Comment").setup({
                toggler = {
                    ---Line-comment toggle keymap
                    line = '<Leader>cc',
                    ---Block-comment toggle keymap
                    block = '<Leader>cb',
                },
                opleader = {
                    ---Line-comment keymap
                    line = '<Leader>cc',
                    ---Block-comment keymap
                    block = '<Leader>cb',
                },
                mappings = {
                    ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
                    basic = true,
                    ---Extra mapping; `gco`, `gcO`, `gcA`
                    extra = false,
                },
            })
        end},
        -- Mark signs
        {"chentoast/marks.nvim",
            config =  true,
            -- m; to toggle next available mark
        },
        -- Git support
        {"lewis6991/gitsigns.nvim",
            name = 'gitsigns',
            config = true,
            event = "BufReadPre",},
        {"NeogitOrg/neogit",
            dependencies = { "nvim-lua/plenary.nvim"},
            config = true,
            cmd = "Neogit",
        },
        {'tpope/vim-fugitive'},
        {'tpope/vim-rhubarb'}, -- github
        -- LSP
        {"neovim/nvim-lspconfig", -- Core LSP plugin
            "williamboman/mason.nvim",  -- Manages LSP servers
            "williamboman/mason-lspconfig.nvim",  -- Bridges Mason and LSPconfig
            "hrsh7th/nvim-cmp",  -- Autocompletion
            "hrsh7th/cmp-nvim-lsp",  -- LSP completion source
        },
        -- Treesitter
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            event = { "BufReadPost", "BufNewFile" }, -- make sure it actually loads
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
                    auto_install = true,

                    highlight = {
                        enable = true,
                        additional_vim_regex_highlighting = false, -- IMPORTANT: stop Vim C syntax from taking over
                    },

                    indent = { enable = true },
                })
            end,
        },
        {
            "nvim-treesitter/nvim-treesitter-textobjects",
            dependencies = { "nvim-treesitter/nvim-treesitter" },
        },
        {
            "nvim-telescope/telescope.nvim",
            dependencies = { "nvim-lua/plenary.nvim" }
        },
        {
            "nvim-treesitter/nvim-treesitter-context",
            event = "VeryLazy",
            config = function()
                require("treesitter-context").setup({
                    enable = true,
                    max_lines = 1,
                    patterns = {
                        default = {
                            "function",
                            "method",
                        }
                    }
                }) end, -- uses default config; or you can pass a function
        },
        {'ranjithshegde/ccls.nvim'},
        'L3MON4D3/luasnip',
        'ThePrimeagen/harpoon',
        -- 'MattesGroeger/vim-bookmarks',
        {
            "windwp/nvim-autopairs",
            event = "InsertEnter",
            config = function()
                require("nvim-autopairs").setup({
                    check_ts = true,  -- Enable Treesitter integration
                    fast_wrap = {},   -- Enable fast wrap feature
                    disable_filetype = { "TelescopePrompt", "vim" }
                })

                -- Integrate with nvim-cmp (if you're using it)
                local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                local cmp = require("cmp")
                cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
            end
        },
        {
            "folke/which-key.nvim",
            event = "VeryLazy",
            opts = {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            },
            keys = {
                {
                    "<leader>?",
                    function()
                        require("which-key").show({ global = false })
                    end,
                    desc = "Buffer Local Keymaps (which-key)",
                },
            },
        },
        { "max397574/better-escape.nvim", config = true, },
        -- { 'echasnovski/mini.ai',          config = true },
        -- {
        {'rmagatti/auto-session',
            lazy = false,

            ---enables autocomplete for opts
            ---@module "auto-session"
            ---@type AutoSession.Config
            opts = {
                suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
                -- log_level = 'debug',
            }
    }

    } --end of spec
})

vim.api.nvim_create_autocmd('BufLeave', {
    pattern = '*',
    callback = function()
        if vim.fn.getbufvar(vim.fn.bufnr('%'), '&buftype') == 'quickfix' then
            vim.cmd('cclose')
        end
    end
})
-- Mason for external tools management
-- It does not support ccls
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "pyright"}, -- Replace with needed LSPs
    automatic_installation = true,
    automatic_enable = {},
})

require("ccls").setup()

require('fzf-lua').setup({
    fzf_colors = {
        -- This changes the background color of the currently selected line
        ["bg+"] = { "bg", "CursorLine" },
        -- This changes the foreground (text) color of the currently selected line
        ["fg+"] = { "fg", "Normal" },
        -- This changes the highlight color for matching text in the selected line
        ["hl+"] = { "fg", "Statement" },
    }
})

local lspconfig = require("lspconfig")
-- Function to attach LSP keybindings
local on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }

    local telescope = require("telescope.builtin")
    local fzf = require("fzf-lua")

    vim.keymap.set("n", "<Space>s", function() fzf.lsp_document_symbols() end, { noremap = true, silent = true, desc = "Symbols" })
    vim.keymap.set("n", "<Space>S", function() fzf.lsp_live_workspace_symbols() end, { noremap = true, silent = true, desc = "All Symbols" })
    vim.keymap.set("n", "gr", function() fzf.lsp_references() end, { noremap = true, silent = true, desc = "References" })
    vim.keymap.set("n", "gd", function() fzf.lsp_definitions() end, { noremap = true, silent = true, desc = "Definitions"})
    vim.keymap.set("n", "gi", function() fzf.lsp_implementations() end, { noremap = true, silent = true, desc = "Impl"})
    vim.keymap.set('v', '=', '<cmd>lua vim.lsp.buf.format()<CR>', {desc = "Format code"})
    vim.keymap.set("n", "<leader>lr", '<cmd>lua vim.lsp.buf.rename()<CR>', {noremap = true, silent = true, desc = "Rename"})

    vim.keymap.set("n", "<leader>r", '<cmd>lua require("ccls.protocol").request("textDocument/references",{role=8})<cr>', {noremap = true, silent = true, buffer = bufnr, desc = "Read Ref"}) -- read
    vim.keymap.set("n", "<leader>w", '<cmd>lua require("ccls.protocol").request("textDocument/references",{role=16})<cr>', {noremap = true, silent = true, buffer = bufnr, desc = "Write Ref"}) -- read
    -- vim.keymap.set("n", "<leader>f", '<cmd>lua require("ccls.protocol").request("textDocument/references",{excludeRole=32})<cr>', opts) -- not call
    -- vim.keymap.set("n", "<leader>m", '<cmd>lua require("ccls.protocol").request("textDocument/references",{role=64})<cr>', opts) -- macro

    -- vim.keymap.set("n", "<space>lc", "<cmd>lua vim.lsp.buf.code_action()<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<space>li", "<cmd>Inspect<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<space>ls", "<cmd>CclsSwitchSourceHeader<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "[e", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "]e", "<cmd>lua vim.diagnostic.goto_next()<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "ga", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "x", "<Nop>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "xB", "<cmd>CclsBaseHierarchy<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "xC", "<cmd>CclsOutgoingCalls<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "xD", "<cmd>CclsDerivedHierarchy<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "xM", "<cmd>CclsMemberHierarchy<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "xb", "<cmd>CclsBase<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "xc", "<cmd>CclsIncomingCalls<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "xd", "<cmd>CclsDerived<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "xi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "xm", "<cmd>CclsMember<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "xn", function() M.lsp.words.jump(vim.v.count1) end, { noremap = true, silent = true })
    -- vim.keymap.set("n", "xp", function() M.lsp.words.jump(-vim.v.count1) end, { noremap = true, silent = true })
    -- vim.keymap.set("n", "xt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "xv", "<cmd>CclsVars<CR>", { noremap = true, silent = true })

    -- Turn off treesitter when lsp server support semantic token
    if client.server_capabilities.semanticTokensProvider then
        vim.api.nvim_set_hl(0, "@lsp.type.parameter", { italic = true })
        vim.treesitter.stop(bufnr)
    end
end

local servers = { "ccls", "lua_ls", "pyright"}

lspconfig.ccls.setup {
    init_options = {
        cache = {
            directory = ".ccls-cache";
        };
    }
}

for _, lsp in ipairs(servers) do
    local options = {
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150,
        }
    }
    if lsp == 'ccls' then
        options = vim.tbl_extend('force', options, {
            init_options = {
                index = {
                    threads = 0,
                    initialBlacklist = {"/(test|unittests)/"},
                };
                --   reference = {
                --     excludeRole = {"definition", "declaration"}
                -- },
            }
        })
    end
    lspconfig[lsp].setup({
        on_attach = on_attach,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })
end

lspconfig.lua_ls.setup {
    on_attach = on_attach,
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc')) then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT'
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME
                    -- Depending on the usage, you might want to add additional paths here.
                    -- "${3rd}/luv/library"
                    -- "${3rd}/busted/library",
                }
                -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
                -- library = vim.api.nvim_get_runtime_file("", true)
            }
        })
    end,
    settings = {
        Lua = {}
    }
}

require'marks'.setup {
  -- whether to map keybinds or not. default true
  default_mappings = true,
  -- which builtin marks to show. default {}
  builtin_marks = { ".", "<", ">", "^" },
  -- whether movements cycle back to the beginning/end of buffer. default true
  cyclic = true,
  -- whether the shada file is updated after modifying uppercase marks. default false
  force_write_shada = false,
  -- how often (in ms) to redraw signs/recompute mark positions.
  -- higher values will have better performance but may cause visual lag,
  -- while lower values may cause performance penalties. default 150.
  refresh_interval = 250,
  -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
  -- marks, and bookmarks.
  -- can be either a table with all/none of the keys, or a single number, in which case
  -- the priority applies to all marks.
  -- default 10.
  sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
  -- disables mark tracking for specific filetypes. default {}
  excluded_filetypes = {},
  -- disables mark tracking for specific buftypes. default {}
  excluded_buftypes = {},
  -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
  -- sign/virttext. Bookmarks can be used to group together positions and quickly move
  -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
  -- default virt_text is "".
  bookmark_0 = {
    sign = "⚑",
    virt_text = "hello world",
    -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
    -- defaults to false.
    annotate = true,
  },
  mappings = {}
}


-- nvim completion
local luasnip = require('luasnip')
local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = {
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        -- ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        -- ['<C-f>'] = cmp.mapping.scroll_docs(4),
        -- ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<Tab>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true
        }),
        ['<C-y>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true
        }),
        -- Enter for next para
        ['<C-j>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ["<C-k>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
        {name = "nvim_lua"}, {name = "look"}
    },
})

require("nvim-treesitter.configs").setup({
    ensure_installed = { "lua", "python", "c", "cpp", "json", "javascript", "bash", "markdown" },
    indent = {enable = true},
    textobjects = {
        select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
            },
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                [']c'] = '@class.outer',
                [']]'] = '@function.outer',
                [']o'] = '@loop.*',
                [']a'] = '@parameter.inner',
            },
            goto_next_end = {
                [']C'] = '@class.outer',
            },
            goto_previous_start = {
                ['[c'] = '@class.outer',
                ['[['] = '@function.outer',
                ['[o'] = '@loop.*',
                ['[a'] = '@parameter.inner',
            },
            goto_previous_end = {
                ['[C'] = '@class.outer',
            },
        },
    },
})

local gitsigns = require('gitsigns')
gitsigns.setup {
  on_attach = function(bufnr)
    local function map(mode, l, r, opts)
      if type(opts) == 'string' then
        opts = { desc = opts }
      else
        opts = {}
      end
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end
    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({ ']c', bang = true })
      else
        gitsigns.nav_hunk('next')
      end
    end, 'next hunk')

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({ '[c', bang = true })
      else
        gitsigns.nav_hunk('prev')
      end
    end, 'prev hunk')

    -- Actions
    map('n', 'ghs', gitsigns.stage_hunk, 'stage_hunk')
    map('n', 'ghr', gitsigns.reset_hunk, 'reset_hunk')
    map('v', 'ghs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
    map('v', 'ghr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
    map('n', 'ghS', gitsigns.stage_buffer, 'stage_buffer')
    map('n', 'ghu', gitsigns.undo_stage_hunk, 'undo_stage_hunk')
    map('n', 'ghR', gitsigns.reset_buffer, 'reset_buffer')
    map('n', 'ghp', gitsigns.preview_hunk, 'preview_hunk')
    map('n', 'ghb', function() gitsigns.blame_line { full = true } end)
    map('n', 'ghd', gitsigns.diffthis, 'diffthis')
    map('n', 'ghD', function() gitsigns.diffthis('~') end, 'diffthis ~')
    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}


-- Mappings
local fzf = require("fzf-lua")
vim.keymap.set("n", "<Space><Space>", function() fzf.files() end, { noremap = true, silent = true, desc = "Files" })
vim.keymap.set("n", "<Space>b", function() fzf.buffers() end, { noremap = true, silent = true , desc = "Buffer"})
vim.keymap.set("n", "<Space>f", function() fzf.live_grep() end, { noremap = true, silent = true, desc = "Search"})
vim.keymap.set("n", "<Space>w", function() fzf.grep_cword() end, { noremap = true, silent = true, desc = "Search CWD" })
vim.keymap.set("n", "<Space>g", function() fzf.git_files() end, { noremap = true, silent = true, desc = "Git Files" })
vim.keymap.set("n", "<Space>t", function() fzf.treesitter() end, { noremap = true, silent = true, desc = "Treesitter" })
vim.keymap.set("n", "<Space>c", function() fzf.commands() end, { noremap = true, silent = true, desc = "Commands" })
vim.keymap.set("n", "<Space>m", function() fzf.marks() end, { noremap = true, silent = true, desc = "Marks" })
vim.api.nvim_create_user_command("F", "FzfLua", {})

-- Motion jumps
local hop = require("hop")
vim.keymap.set('', 's', function() hop.hint_char1({ current_line_only = false }) end, {remap=true})
--
-- hl words
vim.keymap.set("n", "<Leader>h", "<Plug>(quickhl-manual-this)", { noremap = false, silent = true, desc = "Highlight cwd"})
-- get github link of current line
vim.keymap.set("n", "<leader>gl", ":.GBrowse!<CR>", { noremap = true, silent = true, desc = "Git link" })

local hmark = require("harpoon.mark")
local ui = require("harpoon.ui")
vim.keymap.set("n", "<leader>ba", function() hmark.add_file() end, { desc = "Add file to Harpoon" })
vim.keymap.set("n", "<leader>bb", function() ui.toggle_quick_menu() end, { desc = "Open Harpoon UI" })
vim.keymap.set("n", "<leader>bc", function() hmark.clear_all() print("Harpoon marks cleared!") end, { desc = "Clear all Harpoon marks" })
vim.keymap.set("n", "<leader>bh", "<cmd>Telescope harpoon marks<CR>", { desc = "Find Harpoon files with Telescope" })
-- Quickly jump between files (1-4)
vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end, { desc = "Go to file 1" })
vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end, { desc = "Go to file 2" })
vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end, { desc = "Go to file 3" })
vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end, { desc = "Go to file 4" })

vim.keymap.set("n", "J", vim.lsp.buf.hover, { desc = "Show LSP hover docs" })
vim.keymap.set("n", "K", "<cmd>Man<CR>", { desc = "Show manual" , remap = false})
vim.keymap.set("n", "<space>p", '"_diwP', { noremap = true, silent = true, desc = "Replace word by what just yanked" })
vim.keymap.set("v", "<space>p", '"_dP', { noremap = true, silent = true, desc = "Replace selection by what just yanked" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", {noremap = true})
vim.keymap.set("n", "<C-u>", "<C-u>zz", {noremap = true})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local config_path = vim.fn.stdpath("config")

    -- Check if current file is in the nvim config's lua folder
    if bufname:sub(1, #config_path) == config_path then
      vim.keymap.set("n", "K", function()
        local word = vim.fn.expand("<cword>")
          vim.cmd("help " .. word)
      end, { buffer = true, desc = "Show vim help for vim.* or man page", remap = false })
    end
  end,
})

-- vim.keymap.set("n", "<leader>mm", "<Plug>BookmarkToggle", {noremap = true})
-- vim.keymap.set("n", "<leader>ma", "<Plug>BookmarkShowAll", {noremap = true})
-- vim.keymap.set("n", "<leader>mi", "<Plug>BookmarkAnnotate", {noremap = true})
-- vim.keymap.set("n", "<leader>mc", "<Plug>BookmarClear", {noremap = true})
-- vim.api.nvim_del_keymap('n', 'mm')
-- vim.api.nvim_del_keymap('n', 'mi')
-- vim.api.nvim_del_keymap('n', 'mc')
-- vim.api.nvim_del_keymap('n', 'mn')
-- vim.api.nvim_del_keymap('n', 'mp')
-- vim.api.nvim_del_keymap('n', 'mx')
-- vim.api.nvim_del_keymap('n', 'ma')

local function SetMarkWithPrompt(mark)
  local pos = vim.fn.getpos("'" .. mark)
  local line = pos[2]
  local col = pos[3]

  if line ~= 0 or col ~= 0 then
    local msg = "Mark '" .. mark .. "' exists at line " .. line .. ". Overwrite? (y/n): "
    vim.ui.input({ prompt = msg }, function(input)
      if input and input:lower() == "y" then
        vim.cmd("normal! m" .. mark)
        print("Mark '" .. mark .. "' overwritten.")
      else
        print("Mark '" .. mark .. "' not changed.")
      end
    end)
  else
    vim.cmd("normal! m" .. mark)
    print("Mark '" .. mark .. "' set.")
  end
end

-- Remap `ma`, `mb`, ..., `mz` to use the safe prompt
for c = string.byte('a'), string.byte('z') do
  local mark = string.char(c)
  vim.keymap.set('n', 'm' .. mark, function()
    SetMarkWithPrompt(mark)
  end, { noremap = true, silent = true })
end

