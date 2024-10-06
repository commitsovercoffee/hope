--[[ Minima Nvim --------------------------------------------------------------

Minima Nvim is a minimal neovim config that aims to be fast, lightweight,
and easy to use. It is designed for beginners who want to get started with
neovim quickly and easily.

--]]

-- OPTIONS --------------------------------------------------------------------

-- vim.o options are variables that control the behavior of neovim. They can
-- be set to change the appearance of neovim or the way it behaves.

vim.o.autochdir = false      -- change directory to the file in the current window.
vim.o.cdhome = true          -- :cd without an argument changes the cwd to the $HOME dir.

vim.o.fileencoding = "utf-8" -- file encoding for multibyte text.
vim.o.autoread = false       -- read file when changed outside of Vim.

vim.o.wrap = false           -- long lines wrap and continue on the next line.
vim.o.autoindent = true      -- take indent for new line from previous line.
vim.o.scrolloff = 8          -- minimum nr. of lines above and below cursor.

vim.o.incsearch = true       -- highlight match while typing search pattern.
vim.o.smartcase = true       -- no ignore case when pattern has uppercase.

vim.o.number = true          -- print the line number in front of each line.
vim.o.relativenumber = true  -- show relative line number in front of each line.

vim.o.signcolumn = "yes"     -- always display the sign column.
vim.o.colorcolumn = "80"     -- highlight 80th column to indiate optimal code width.
vim.o.cursorline = true      -- highlight the screen line of the cursor.

-- use clipboard register "+" for all yank, delete, change and put operations.
vim.o.clipboard = "unnamedplus"
vim.o.selection = "exclusive" -- what type of selection to use.

vim.o.spell = false           -- enable spell checking.
vim.o.spelllang = "en_us"     -- language(s) to do spell checking for.

vim.o.swapfile = false        -- whether to use a swapfile for a buffer.
vim.o.backup = false          -- keep backup file after overwriting a file.

vim.o.undofile = true         -- save undo information in a file.
vim.o.undodir = vim.fn.expand("~/.config/nvim/undodir")

vim.o.background = "dark" -- use "dark" or "light" for highlight
vim.g.mapleader = " "     -- setting space as leader key.

-- PLUGIN MANAGER -------------------------------------------------------------

-- vim.o will only lets you set "internal" variables. To add more features, you
-- can install plugins. For this, we will need a plugin manager, which
-- is a tool that helps you install, update, and manage plugins for Neovim.

-- install "lazy" plugin manager ...
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- setup ...
require("lazy").setup({

	-- PLUGINS  -----------------------------------------------------------
	-- Here you can add plugins to extend functionality of neovim.

	-- Colorscheme ~ make it beautiful !
	{
		"catppuccin/nvim",
		priority = 1000,
		config = function()
			vim.cmd("colorscheme catppuccin-mocha")
		end,
	},

	-- A File-explorer. duh ! ( this is not a file tree. )
	-- You can edit this as a normal neovim buffer.
	{
		"stevearc/oil.nvim",
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup({
				keymaps = {
					["<BS>"] = "actions.parent",
				},
				vim.keymap.set("n", "<leader>ee", require("oil").open, {}),
			})
		end,
	},

	-- A terminal. sudo away !
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 20,
				open_mapping = [[<c-space>]], -- use [Ctrl][Space] to toggle terminal.
				direction = "float",
			})
		end,
	},

	-- A statusline. So you can ignore the useful info.
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				icons_enabled = true,
				theme = "catppuccin-mocha",
				component_separators = "|",
				section_separators = "",
			},
		},
		config = function()
			require("lualine").setup({})
		end,
	},

	-- A fuzzy finder. Trust me, you want it.
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({
				-- [leader][ff] will open fuzzy finder in "find files" mode. And so on ...
				vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, {}),
				vim.keymap.set("n", "<leader>gg", require("telescope.builtin").live_grep, {}),
				vim.keymap.set("n", "<leader>gc", require("telescope.builtin").git_commits, {}),
				vim.keymap.set("n", "<leader>gb", require("telescope.builtin").git_branches, {}),
				vim.keymap.set("n", "<leader>fd", require("telescope.builtin").diagnostics, {}),
			})
		end,
	},

	-- A session manager. Blink back to work !
	{
		"rmagatti/auto-session", -- save a session using ":SessionSave".
		config = function()
			require("auto-session").setup({
				log_level = "error",
				auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
				vim.keymap.set("n", "<leader>ss", require("auto-session.session-lens").search_session, {}),
			})
		end,
	},

	-- Syntax highlighting.
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				highlight = {
					enable = true,
					-- Disable slow treesitter highlight for large files
					disable = function(lang, buf)
						local max_filesize = 100 * 1024 -- 100 KB
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,
					additional_vim_regex_highlighting = false,
				},
			})
		end,
	},

	-- Visual multi cursor.
	{
		"mg979/vim-visual-multi",
		config = function()
			require("vim-visual-multi").setup({})
		end,
	},

	-- Search label based code navigation
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {},
		-- stylua: ignore
		keys = {
			{ "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
		},
	},

	-- Auto pairs braces
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},

	-- Auto closes tags
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup({})
		end,
	},

	-- Indents blank lines
	"lukas-reineke/indent-blankline.nvim",

	-- Run git commands from neovim using commands like ":Git log" or ":Git status".
	"tpope/vim-fugitive",

	-- Go development plugin for vim/neovim.
	"fatih/vim-go",

	{
		-- Git signs.
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				change = { text = "~" },
				add = { text = "+" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	-- Rust development plugin
	{
		"mrcjkb/rustaceanvim",
		version = "^4", -- Recommended
		lazy = false, -- This plugin is already lazy
	},

	{

		"rust-lang/rust.vim",
		ft = "rust",
		init = function()
			vim.g.rustfmt_autosave = 1
		end,
	},

	{
		"mrjones2014/smart-splits.nvim",
		config = function()
			require("smart-splits").setup({
				default_amount = 20,
				-- moving between splits
				vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left),
				vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down),
				vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up),
				vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right),
			})
		end,
	},

	--[[

Up to this point, we have completed some basic one-time setup, including adding
a file explorer, terminal, statusline, fuzzy finder, session manager and
automatic syntax highlighting.

In addition to these basic functionalities, you may need a :
- lsp : language server for code completion, warnings, errors etc.
- formatter : to format your code to a consistent style.
- linter : to check your code for errors and potential problems.
- dap : debug adapter protocol, to debug your code in neovim.

--]]

	-- We can install either of these with mason using the ":Mason" command.
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
		config = function()
			require("mason").setup({
				PATH = "prepend", -- "skip" seems to cause the spawning error
			})
		end,
	},

	-- For the packages you install from mason to work, you need to add
	-- them in the config. Follow the step by step process below to do so.

	-- Guide : Setup installed LSP.
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- Step 1 : Visit "https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md"
			-- Step 2 : Search the lsp you installed.
			-- Step 3 : Paste "snippet to enable lsp" command below.

			require("lspconfig").lua_ls.setup({}) -- lua
			require("lspconfig").bashls.setup({}) -- bash
			require("lspconfig").cssls.setup({}) -- css
			require("lspconfig").tailwindcss.setup({}) -- tailwindcss
			require("lspconfig").svelte.setup({}) -- svelte
			require("lspconfig").gopls.setup({}) -- google's lsp for golang

			-- Step 4 : Open file in neovim for which you have installed lsp.
			-- Step 5 : Run ":LspInfo", to verify that lsp is attached.

			-- Global mappings.
			vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

			-- Map keys if language server attaches to the current buffer.
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),

				callback = function(ev)
					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions.
					local opts = { buffer = ev.buf }
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
					vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)

					vim.keymap.set("n", "<space>wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, opts)

					vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				end,
			})
		end,
	},

	-- Guide : Setup installed formatter or linter.
	{
		"nvimtools/none-ls.nvim",
		config = function()
			require("null-ls").setup({
				sources = {

					-- Step 1 : Visit "https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#formatting"
					-- Step 2 : Search the formatter or linter you installed.
					-- Step 3 : Paste "usage" command below.

					require("null-ls").builtins.code_actions.gitsigns,
					require("null-ls").builtins.formatting.stylua,
					require("null-ls").builtins.formatting.astyle,
					require("null-ls").builtins.formatting.goimports,
					require("null-ls").builtins.formatting.gofumpt,
					require("null-ls").builtins.formatting.prettier.with({
						filetypes = {
							"bash",
							"json",
							"yaml",
							"html",
							"css",
							"javascript",
							"svelte",
							"csh",
							"ksh",
							"sh",
							"zsh",
							"markdown",
						},
					}),

					-- Step 4 : Open file for which you have installed formatter.
					-- Step 5 : Run ":LspInfo", you should see the client "null-ls".
				},
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ async = false })
							end,
						})
					end
				end,
			})
		end,
	},

	-- Only one functionality remains to be added now i.e auto-completion.
	-- To make that work, we install below plugins.
	{
		"L3MON4D3/LuaSnip", -- snippet engine
		dependencies = { "rafamadriz/friendly-snippets" },
		-- follow latest release.
		version = "2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
	},

	{
		"hrsh7th/nvim-cmp", -- completion plugin
		-- source for ...
		"hrsh7th/cmp-nvim-lsp", -- builtin LSP client.
		"hrsh7th/cmp-buffer", -- buffer words.
		"hrsh7th/cmp-path", -- path.
		"hrsh7th/cmp-calc", -- math calculation.
		"saadparwaiz1/cmp_luasnip", -- luasnip.
		"hrsh7th/cmp-cmdline", -- vim's cmdline.
	},
}, {})

-- Auto Completion Config  ----------------------------------------------------

-- add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- load the snippets contained in the plugin on startup.
require("luasnip.loaders.from_vscode").lazy_load()

local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- auto-completion setup ...
local luasnip = require("luasnip")
local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
		["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
		-- C-b (back) C-f (forward) for snippet placeholder navigation.
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),

		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
				-- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
				-- they way you will only jump inside the snippet region
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {

		{ name = "nvim_lsp" },
		{ name = "buffer" },
		{ name = "path" },
		{ name = "calc" },
		{ name = "luasnip" },
	},
})

-- `:` cmdline setup.
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{
			name = "cmdline",
			option = {
				ignore_cmds = { "Man", "!" },
			},
		},
	}),
})

-- Keymaps --------------------------------------------------------------------
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map("n", "<leader>ww", ":w<CR>") -- save
map("n", "<leader>qq", ":q<CR>") -- quit

-- Commands for toggleterm
function _G.set_terminal_keymaps()
	local opts = { buffer = 0 }
	vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
	vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
	vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
	vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
	vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
	vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
	vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

-- Neovide --------------------------------------------------------------------

if vim.g.neovide then
	-- Put anything you want to happen only in Neovide here
	vim.o.guifont = "FiraCode Nerd Font Mono:size=16"
end
