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

M.setup = function()
	core.setup()
	vim.wait(100)
	core.command('commands', getcomps(M.commands, echo))
	core.command('listall', getcomps(M.files, escape))
end

-- format output example.
local displaySong = function(tbl)
	return string.format('%2d: %s / %s - %s', tbl.Track, tbl.Title, tbl.Artist, tbl.Album)
end
local format_all = function(s, f, d)
	for _, v in util.devide(s) do table.insert(d, f(v)) end; return d
end
local printer = function(result) print(table.concat(result, '\n')) end
local printsongs = function(r) printer(format_all(r, displaySong, {})) end

M.print = function(opts) core.command(opts.args, printer) end
M.nowplaying = function() core.command('currentsong', printsongs) end
M.queue = function() core.command('playlistinfo', printsongs) end

return M
