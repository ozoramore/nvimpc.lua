local M = {}
local util = require('nvimpc.util')

M.config = {
	host = "localhost",
	addr = nil,
	port = 6600,
	password = nil,
	isv6 = false,
}

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	local family_type = M.config.isv6 and "inetv6" or "inet"

	if not M.config.addr then
		local info = vim.uv.getaddrinfo(M.config.host, nil, { family = family_type })
		M.config.addr = info[1].addr
	end
end

M.result = {}

M.command = function(data)
	local writebuf, resultbuf = data .. '\n', ""
	local client = vim.uv.new_tcp()
	assert(client, "new tcp fail")
	client:send_buffer_size()

	--
	-- callback関数の定義
	--

	local on_shutdown = function()
		client:close()
	end

	local on_read_start = function(status, buf)
		assert(not status, status)
		if type(buf) == 'string' and string.len(buf) ~= 0 then
			resultbuf = resultbuf .. buf
		else
			client:write('close\n')
			client:shutdown(on_shutdown)
		end
	end

	local on_write = function(status)
		assert(not status, status)
		client:read_start(on_read_start)
	end

	local on_connect = function(status)
		assert(not status, status)
		client:write(writebuf, on_write)
	end

	--
	-- callback関数の定義 end
	--

	client:connect(M.config.addr, M.config.port, on_connect)

	vim.wait(100)

	M.result = util.split(resultbuf, nil)
end


return M
