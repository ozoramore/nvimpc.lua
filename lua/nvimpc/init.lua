local M = {}

local core = require('nvimpc.core')
local util = require('nvimpc.util')

M.setup = core.setup

M.exec = function(opts)
	core.command(opts.args)
	print(table.concat(core.result, '\n'))
end

-- format output example.

local displaySong = function(tbl)
	print(string.format("%2d: %s / %s - %s", tbl.Track, tbl.Title, tbl.Artist, tbl.Album))
end

M.nowplaying = function()
	core.command('currentsong')
	displaySong(util.parse(core.result))
end

M.queue = function()
	core.command('playlistinfo')
	for _, v in util.devide(core.result) do displaySong(v) end
end

return M
