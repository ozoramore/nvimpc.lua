local M = {}

local core = require('nvimpc.core')
local util = require('nvimpc.util')

M.commands = {}
M.files = {}

local strescape = function(s)
	s = string.gsub(s, "\\", "\\\\")
	s = string.gsub(s, "\"", "\\\"")
	s = string.gsub(s, "\'", "\\\'")
	return '"' .. s .. '"'
end

local getcompswithescape = function(tbl)
	return function(result)
		for _, l in ipairs(result) do
			for s in string.gmatch(l, '.+: (.+)') do table.insert(tbl, strescape(s)) end
		end
	end
end

local getcomps = function(tbl)
	return function(result)
		for _, l in ipairs(result) do
			for s in string.gmatch(l, '.+: (.+)') do table.insert(tbl, s) end
		end
	end
end

M.setup = function()
	core.setup()
	vim.wait(100)
	core.command('commands', getcomps(M.commands))
	core.command('listall', getcompswithescape(M.files))
end

local command_gen = function(cb) return function(opts) core.command(opts.args, cb) end end
M.print = command_gen(function(result) print(table.concat(result, '\n')) end)

-- format output example.
local format_all = function(formatter, result)
	local tbl = {}
	for _, v in util.devide(result) do table.insert(tbl, formatter(v)) end
	return tbl
end
local displaySong = function(tbl)
	return string.format('%2d: %s / %s - %s', tbl.Track, tbl.Title, tbl.Artist, tbl.Album)
end
local printsongs = function(result) print(table.concat(format_all(displaySong, result), '\n')) end

M.nowplaying = function() core.command('currentsong', printsongs) end
M.queue = function() core.command('playlistinfo', printsongs) end

return M
