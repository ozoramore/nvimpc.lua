local M = {}
M.commands = {}
M.files = {}

local core = require('nvimpc.core')
local util = require('nvimpc.util')
local Str = require('nvimpc.str')

local echo = function(s) return s end
local escape = function(s)
	local str = Str.new():set(s)
	return str:tr("\\", "\\\\"):tr("\"", "\\\""):tr("\'", "\\\'"):srr('"'):get()
end

local getcomps = function(tbl, func)
	return function(result)
		for _, l in ipairs(result) do
			for s in string.gmatch(l, '.+: (.+)') do table.insert(tbl, func(s)) end
		end
	end
end

M.setup = function(opts)
	core.setup(opts)
	vim.wait(100)
	core.command('commands', getcomps(M.commands, echo))
	core.command('listall', getcomps(M.files, escape))
end
M.print = function(opts) core.command(opts.args, util.printer) end
M.gen = function(cmd, cb) return function(_) core.command(cmd, cb) end end

return M
