local uv = vim.uv
local M = {}

M.connection = nil

M.config = {
	host = 'localhost',
	port = 6600,
	password = nil
}

local function connect(opts)
	local client = uv.new_tcp()
	client:connect( M.config.host, M.config.port, function(err) print(err) end )
	uv.run()
end

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end



return M
