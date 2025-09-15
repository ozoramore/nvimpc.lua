---@type string[]
local commands = {}

local core = require('nvimpc.core')
local util = require('nvimpc.util')

---Store the command results in `commands` table.
---@param r string[]
local commands_cb = function(r)
	for _, l in ipairs(r) do
		for s in string.gmatch(l, '.+: (.+)') do table.insert(commands, s) end
	end
end

---Commands List Completion
---@param a string
---@param l string
---@param _ any
---@return any[]|nil error
local commands_comp = function(a, l, _)
	local filter = function(i) return vim.startswith(i, a) end
	local args = #util.split(l, ' ')
	if args > 2 then return nil end
	if args == 2 and a == '' then return nil end
	return vim.tbl_filter(filter, commands)
end

---execute commands and print.
---@param opts any
local execfunc = function(opts) core.exec(opts.args, util.printer) end

local M = {}

M.exec = core.exec

---usercommand generator
---@param cmd string command
---@param cb function callback
---@return function user_command
M.gen = function(cmd, cb) return function(_) core.exec(cmd, cb) end end


---setup functions
---@param opts table
M.setup = function(opts)
	core.setup(opts)
	vim.wait(100)
	core.exec('commands', commands_cb)
	vim.api.nvim_create_user_command('Mpc', execfunc, { nargs = '*', complete = commands_comp })
end

return M
