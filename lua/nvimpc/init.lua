local M = {}

local core = require('nvimpc.core')
local util = require('nvimpc.util')

M.setup = core.setup

M.exec = function(opts)
	local exec = function(result) print(table.concat(result, '\n')) end
	core.command(opts.args, exec)
end

-- format output example.

local displaySong = function(tbl)
	return string.format("%2d: %s / %s - %s", tbl.Track, tbl.Title, tbl.Artist, tbl.Album)
end

M.nowplaying = function()
	local nowplaying = function(result) print(displaySong(util.parse(result))) end
	core.command('currentsong', nowplaying)
end

M.queue = function()
	local queue = function(result)
		local tbl = {}
		for _, v in util.devide(result) do
			table.insert(tbl, displaySong(v))
		end
		print(table.concat(tbl, '\n'))
	end
	core.command('playlistinfo', queue)
end

return M
