local uv = vim.uv
local M = {}

M.connection = nil

M.config = {
	host = "localhost",
	port = 6600,
	password = nil,
}

local client
M.connect = function()
end

M.buf = ""
M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	client = uv.new_tcp()
	local userdata = client:connect(M.config.host, M.config.port)
	local sock = client:send_buffer_size()
	client:open(sock)
	client:read_start(function(err, chunk)
		assert(not err, err)
		if chunk then
			M.buf = chunk
		end
	end)
	uv.run()
end

M.command = function(opts)
	client:write(opts .. "\nclose\n")
	uv.run()
end

return M
