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

	if not M.config.addr then
		local family_type = 'inet'
		if M.config.isv6 then family_type = "inetv6" end
		local info = vim.uv.getaddrinfo(M.config.host, nil, { family = family_type })
		M.config.addr = info[1].addr
	end
end

local is_connect = false

local disconnect = function(client)
	if not client then return nil end
	if not is_connect then return end
	local on_close = function()
		client:close()
		client:shutdown()
		is_connect = false
	end

	client:write('close\n', on_close)
	vim.wait(100)
end

local write = function(client, data)
	if not client then return nil end
	if not is_connect then return nil end
	local resultbuf = ""
	local on_read_start = function(status, buf)
		assert(not status, status)
		if buf then resultbuf = resultbuf .. buf else disconnect(client) end
	end
	local on_write = function(status)
		assert(not status, status)
		client:read_start(on_read_start)
	end

	client:write(data .. '\n', on_write)
	vim.wait(100)
	return resultbuf
end

local connect = function()
	if is_connect then return nil end
	local on_connect = function(status)
		assert(not status, status)
		is_connect = true
	end

	local client = vim.uv.new_tcp()
	assert(client, "new tcp fail")
	if not client then return nil end

	client:send_buffer_size()
	client:connect(M.config.addr, M.config.port, on_connect)
	vim.wait(100)

	return client
end

M.command = function(data)
	local client = connect()
	if not client then return nil end
	local response = write(client, data)
	disconnect(client)
	if not response then return nil end

	local result = util.split(response, '\n')
	M.result = result
	return result
end

return M
