local M = {}
M.commands = {}

local core = require('nvimpc.core')
local util = require('nvimpc.util')

local commands_cb = function(r)
	for _, l in ipairs(r) do
		for s in string.gmatch(l, '.+: (.+)') do table.insert(M.commands, s) end
	end
end

local commands_comp = function(a, l, _)
	local filter = function(i) return vim.startswith(i, a) end
	local args = #util.split(l, ' ')
	if args > 2 then return nil end
	if args == 2 and a == '' then return nil end
	return vim.tbl_filter(filter, M.commands)
end

local execfunc = function(opts) core.exec(opts.args, util.printer) end

M.setup = function(opts)
	core.setup(opts)
	vim.wait(100)
	core.exec('commands', commands_cb)
	M.exec = core.exec
	M.gen = function(cmd, cb) return function(_) core.exec(cmd, cb) end end
	vim.api.nvim_create_user_command('Mpc', execfunc, { nargs = '*', complete = commands_comp })
end

return M
