local M = {}

local core = require('nvimpc.core')
local util = require('nvimpc.util')

M.setup = core.setup
M.command = core.command

local display = function(tbl)
	print(tbl.Pos, '\t: ', tbl.Title, '/', tbl.Artist, '-', tbl.Album)
end

M.nowplaying = function()
	core.command('currentsong')
	display(util.parse(core.result))
end

M.queue = function()
	core.command('playlistinfo')
	for _, v in ipairs(core.result) do
		display(util.parse(v))
	end
end

M.exec = function(opts)
	core.command(opts.args)
	print(table.concat(core.result, '\n'))
end

return M
