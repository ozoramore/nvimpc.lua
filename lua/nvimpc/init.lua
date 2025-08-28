local M = {}

local core = require('nvimpc.core')
local util = require('nvimpc.util')

M.setup = core.setup
M.exec = function(opts) core.command(opts.args, function(result) print(table.concat(result, '\n')) end) end

-- format output example.

local displaySong = function(tbl)
	return string.format("%2d: %s / %s - %s", tbl.Track, tbl.Title, tbl.Artist, tbl.Album)
end

local format_all = function(formatter, result)
	local tbl = {}
	for _, v in util.devide(result) do table.insert(tbl, formatter(v)) end
	return tbl
end

M.nowplaying = function()
	core.command('currentsong', function(r) print(table.concat(format_all(displaySong, r), '\n')) end)
end

M.queue = function()
	core.command('playlistinfo', function(r) print(table.concat(format_all(displaySong, r), '\n')) end)
end

return M
