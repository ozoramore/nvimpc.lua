local mpd = require('mpd')
local M = {}

function M.setup(opts)
	return mpd.new(opts)
end

return M
