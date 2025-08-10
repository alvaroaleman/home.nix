vim.opt.autoindent = true
vim.opt.tabstop = 2
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.splitright = true
vim.opt.mouse = ""

vim.opt.clipboard = vim.opt.clipboard + "unnamedplus"
if vim.env.SSH_TTY or vim.env.SSH_CLIENT or vim.env.SSH_CONNECTION then
	local function osc52_copy(text)
		local base64_text = vim.fn.system('base64 -w0', text)
		base64_text = string.gsub(base64_text, '\n', '')
		io.stdout:write('\027]52;c;' .. base64_text .. '\027\\')
		io.stdout:flush()
	end

	vim.g.clipboard = {
		name = 'OSC 52',
		copy = {
			['+'] = function(lines)
				osc52_copy(table.concat(lines, '\n'))
				return lines
			end,
			['*'] = function(lines)
				osc52_copy(table.concat(lines, '\n'))
				return lines
			end,
		},
	}
end

-- Disable swapfiles so different neovim instances do not prevent each other
-- from opening the file.
vim.opt.swapfile = false
-- Automically reload files when they change on disk.
vim.opt.autoread = true
-- Switch between buffers without saving.
vim.opt.hidden = true

-- Airline configuration
vim.cmd("let g:airline#extensions#tabline#enabled=1")
vim.cmd("let g:airline#extensions#tabline#show_buffers=0")
vim.cmd("let g:airline#extensions#tabline#tab_nr_type=1")
vim.cmd("let g:airline#extensions#tabline#show_tab_type=0")
vim.cmd("let g:airline_disable_statusline = 1")
vim.cmd("let g:airline_theme='distinguished'")

local parser_install_dir = vim.fn.stdpath("data") .. "/treesitter"
vim.opt.runtimepath:prepend(parser_install_dir)

require("nvim-treesitter.configs").setup({
	modules = {},
	ensure_installed = {}, -- Empty, managed by Nix
	ignore_install = {},
	sync_install = false,
	parser_install_dir = parser_install_dir,
	auto_install = true, -- Disabled, managed by Nix
	highlight = {
		enable = true,
	},
})

require("nvim-autopairs").setup {}
require("ibl").setup {}

require("illuminate").configure({
	delay = 200,
	large_file_cutoff = 2000,
	large_file_overrides = {
		providers = { "lsp" },
	},
})

-- Illuminate keymaps
local function map(key, dir, buffer)
	vim.keymap.set("n", key, function()
		require("illuminate")["goto_" .. dir .. "_reference"](false)
	end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
end

map("]]", "next")
map("[[", "prev")

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		local buffer = vim.api.nvim_get_current_buf()
		map("]]", "next", buffer)
		map("[[", "prev", buffer)
	end,
})

-- Gitsigns setup
require("gitsigns").setup({
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
		untracked = { text = "▎" },
	},
})

-- LSP signature setup
require("lsp_signature").setup({
	bind = true,
	handler_opts = {
		border = "rounded"
	}
})

-- Treesitter context
require("treesitter-context").setup({ separator = "-" })
vim.cmd('TSContextEnable')

-- UFO (folding) setup
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:,diff:/]]

vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
require('ufo').setup({
	provider_selector = function(_, _, _)
		return { 'treesitter', 'indent' }
	end
})

-- Statuscol setup
local builtin = require("statuscol.builtin")
require("statuscol").setup({
	setopt = true,
	segments = {
		{ text = { "%s" },             click = "v:lua.ScSa" },
		{ text = { builtin.foldfunc }, click = "v:lua.ScFa" },
		{
			text = { builtin.lnumfunc, " " },
			condition = { true, builtin.not_empty },
			click = "v:lua.ScLa",
		},
	}
})

-- Fidget setup
require("fidget").setup {}

-- Copilot setup
require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
})
require("copilot_cmp").setup()

-- Bigfile setup
require("bigfile").setup({
	pattern = function(bufnr, filesize_mib)
		if filesize_mib >= 2 then
			return true
		end
		local file_contents = vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))
		local line_count = #file_contents
		if line_count > 30000 then
			return true
		end
		for _, line in ipairs(file_contents) do
			if #line > 6000 then
				return true
			end
		end
	end,
	features = {
		"indent_blankline",
		"illuminate",
		"lsp",
		"treesitter",
		"syntax",
		"matchparen",
		"vimopts",
	},
})

-- Vimade setup
require('vimade').setup({
	recipe = { 'default', { animate = false } },
	ncmode = 'buffers',
	fadelevel = 0.8,
	basebg = '',
	tint = {},
	blocklist = {
		default = {
			highlights = {
				laststatus_3 = function(win, active)
					if vim.go.laststatus == 3 then
						return 'StatusLine'
					end
				end,
				'TabLineSel',
				'Pmenu',
				'PmenuSel',
				'PmenuKind',
				'PmenuKindSel',
				'PmenuExtra',
				'PmenuExtraSel',
				'PmenuSbar',
				'PmenuThumb',
			},
			buf_opts = { buftype = { 'prompt' } },
		},
		default_block_floats = function(win, active)
			return win.win_config.relative ~= '' and
			    (win ~= active or win.buf_opts.buftype == 'terminal') and true or false
		end,
	},
	link = {},
	groupdiff = true,
	groupscrollbind = false,
	enablefocusfading = false,
	checkinterval = 1000,
	usecursorhold = false,
	nohlcheck = true,
	focus = {
		providers = {
			filetypes = {
				default = {
					{ 'treesitter', {
						min_node_size = 2,
						min_size = 1,
						max_size = 0,
						exclude = {
							'script_file',
							'stream',
							'document',
							'source_file',
							'translation_unit',
							'chunk',
							'module',
							'stylesheet',
							'statement_block',
							'block',
							'pair',
							'program',
							'switch_case',
							'catch_clause',
							'finally_clause',
							'property_signature',
							'dictionary',
							'assignment',
							'expression_statement',
							'compound_statement',
						}
					} },
					{ 'blanks', {
						min_size = 1,
						max_size = '35%'
					} },
					{ 'static', {
						size = '35%'
					} },
				},
			},
		}
	},
})

-- CMP setup
vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
local cmp = require("cmp")
local defaults = require("cmp.config.default")()
local luasnip = require('luasnip')
local lspkind = require('lspkind')

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
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
	formatting = {
		format = lspkind.cmp_format({
			mode = 'symbol_text',
			maxwidth = 50,
			before = function(_, vim_item)
				return vim_item
			end
		})
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
		{ name = 'nvim_lua' },
		{ name = 'nvim_lsp_signature_help' },
		{ name = 'path',                   option = { trailing_slash = true } },
		{
			name = 'buffer',
			max_item_count = 3,
			keyword_length = 2,
		},
		{ name = "copilot", group_index = 2 },
	}),
	experimental = {
		ghost_text = {
			hl_group = "CmpGhostText",
		},
	},
	sorting = defaults.sorting,
})

-- LSP configuration (no Mason setup needed)
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lsp_servers = { "clangd", "gopls", "pylsp", "terraformls", "nixd", "rust_analyzer" }
for _, server in ipairs(lsp_servers) do
	lspconfig[server].setup {
		capabilities = capabilities,
	}
end


lspconfig.gopls.setup {
	cmd = { 'gopls', "-remote=auto", "-logfile=/tmp/gopls.log", "-rpc.trace" },
	filetypes = { "go", "gomod" },
	root_dir = require("lspconfig/util").root_pattern("go.work", "go.mod", ".git"),
	capabilities = capabilities,
	settings = {
		gopls = {
			env = { GOFLAGS = "-tags=integration,tools" },
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
}

lspconfig.lua_ls.setup {
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			},
			diagnostics = {
				globals = { 'vim', 'use' },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = {
				enable = false,
			},
		},
	},
}

-- Global LSP mappings
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- LSP attach autocommand
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'h', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set('n', '<space>wl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set('n', 'gT', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<space>f', function()
			vim.lsp.buf.format { async = true }
		end, opts)
	end,
})

-- Gruvbox theme setup
local config = require("gruvbox").config
local colors = require("gruvbox.palette").get_base_colors(vim.o.background, config.contrast)
require("gruvbox").setup({
	overrides = {
		SignColumn = {
			bg = colors.bg0,
		},
		LineNr = { fg = colors.bg4, bg = colors.bg0 },
		FoldColumn = config.transparent_mode and { fg = colors.gray, bg = nil } or
		    { fg = colors.gray, bg = colors.bg0 },
		GitSignsAdd = config.transparent_mode and { fg = colors.green, reverse = config.invert_signs }
		    or { fg = colors.green, bg = colors.bg0, reverse = config.invert_signs },
		GitSignsChange = config.transparent_mode and { fg = colors.aqua, reverse = config.invert_signs }
		    or { fg = colors.aqua, bg = colors.bg0, reverse = config.invert_signs },
		GitSignsDelete = config.transparent_mode and { fg = colors.red, reverse = config.invert_signs }
		    or { fg = colors.red, bg = colors.bg0, reverse = config.invert_signs },
		GruvboxRedSign = config.transparent_mode and { fg = colors.red, reverse = config.invert_signs }
		    or { fg = colors.red, bg = colors.bg0, reverse = config.invert_signs },
		GruvboxGreenSign = config.transparent_mode and { fg = colors.green, reverse = config.invert_signs }
		    or { fg = colors.green, bg = colors.bg0, reverse = config.invert_signs },
		GruvboxYellowSign = config.transparent_mode and { fg = colors.yellow, reverse = config.invert_signs }
		    or { fg = colors.yellow, bg = colors.bg0, reverse = config.invert_signs },
		GruvboxBlueSign = config.transparent_mode and { fg = colors.blue, reverse = config.invert_signs }
		    or { fg = colors.blue, bg = colors.bg0, reverse = config.invert_signs },
		GruvboxPurpleSign = config.transparent_mode and { fg = colors.purple, reverse = config.invert_signs }
		    or { fg = colors.purple, bg = colors.bg0, reverse = config.invert_signs },
		GruvboxAquaSign = config.transparent_mode and { fg = colors.aqua, reverse = config.invert_signs }
		    or { fg = colors.aqua, bg = colors.bg0, reverse = config.invert_signs },
		GruvboxOrangeSign = config.transparent_mode and { fg = colors.orange, reverse = config.invert_signs }
		    or { fg = colors.orange, bg = colors.bg0, reverse = config.invert_signs },
	},
	italic = {
		strings = false,
		comments = false,
		operators = false,
		folds = false,
	},
})
vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")

-- Autocommands
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format({ async = false, timeout_ms = 2000 })]]
vim.cmd('autocmd BufWritePre * :%s/\\s\\+$//e')

-- Go organize imports
local function org_imports()
	local clients = vim.lsp.buf_get_clients()
	for _, client in pairs(clients) do
		local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
		params.context = { only = { "source.organizeImports" } }

		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 5000)
		for _, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
				else
					vim.lsp.buf.execute_command(r.command)
				end
			end
		end
	end
end

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.go" },
	callback = org_imports,
})

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "⚠",
			[vim.diagnostic.severity.WARN] = "⚠",
			[vim.diagnostic.severity.HINT] = "",
			[vim.diagnostic.severity.INFO] = "",
		},
	}
})
require("trouble").setup()
vim.keymap.set("n", "ld", function()
	require("trouble").toggle({
		mode = "diagnostics",
		filter = {
			buf = 0,
			range = {
				start = { vim.fn.line("."), 0 },
				["end"] = { vim.fn.line("."), -1 }
			}
		}
	})
end, { desc = "Line Diagnostics (Trouble)" })

-- Custom LSP rename function
function LspRename()
	local curr_name = vim.fn.expand("<cword>")
	local value = vim.fn.input("LSP Rename: ", curr_name)
	local lsp_params = vim.lsp.util.make_position_params()

	if not value or #value == 0 or curr_name == value then return end

	lsp_params.newName = value
	vim.lsp.buf_request(0, "textDocument/rename", lsp_params, function(_, res, ctx, _)
		if not res then return end

		local client = vim.lsp.get_client_by_id(ctx.client_id)
		vim.lsp.util.apply_workspace_edit(res, client.offset_encoding)

		local changed_files_count = 0
		local changed_instances_count = 0

		if (res.documentChanges) then
			for _, changed_file in pairs(res.documentChanges) do
				changed_files_count = changed_files_count + 1
				changed_instances_count = changed_instances_count + #changed_file.edits
			end
		elseif (res.changes) then
			for _, changed_file in pairs(res.changes) do
				changed_instances_count = changed_instances_count + #changed_file
				changed_files_count = changed_files_count + 1
			end
		end

		print(string.format("renamed %s instance%s in %s file%s. %s",
			changed_instances_count,
			changed_instances_count == 1 and '' or 's',
			changed_files_count,
			changed_files_count == 1 and '' or 's',
			changed_files_count > 1 and "To save them run ':wa'" or ''
		))
	end)
end

-- Additional keymaps
vim.keymap.set('n', 'rn', LspRename)
vim.cmd('autocmd FileType * :setlocal spell spelllang=en_us')
vim.cmd(':nmap cp :let @+ = expand("%")<cr>')
vim.cmd(':nmap em :RustLsp expandMacro<cr>')

-- Rainbow delimiters setup
local rainbow_delimiters = require 'rainbow-delimiters'

vim.g.rainbow_delimiters = {
	strategy = {
		[''] = rainbow_delimiters.strategy['global'],
		vim = rainbow_delimiters.strategy['local'],
	},
	query = {
		[''] = 'rainbow-delimiters',
		lua = 'rainbow-blocks',
	},
	highlight = {
		'RainbowDelimiterRed',
		'RainbowDelimiterYellow',
		'RainbowDelimiterBlue',
		'RainbowDelimiterOrange',
		'RainbowDelimiterGreen',
		'RainbowDelimiterViolet',
		'RainbowDelimiterCyan',
	},
}

require('lspconfig').nixd.setup({
	settings = {
		nixd = {
			formatting = {
				command = { "alejandra" }
			}
		}
	}
})
