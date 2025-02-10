local function split(str, ts)
	ts = ts or "\n"
	local t = {}
	local i = 1
	for s in string.gmatch(str, "([^" .. ts .. "]+)") do
		t[i] = s
		i = i + 1
	end
	return t
end

local uv = vim.uv

local M = {}

M.config = {
	host = "localhost",
	addr = nil,
	port = 6600,
	password = nil,
	isv6 = false,
}

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	local family_type = "inet"
	if M.config.isv6 then
		family_type = "inetv6"
	end
	M.config.addr = M.config.addr or uv.getaddrinfo(M.config.host, nil, { family = family_type })[1].addr
end

M.result = {}

M.command = function(data)
	local is_connect = true
	local writebuf = data .. "\nclose\n"
	local resultbuf = ""
	local client = uv.new_tcp()
	assert(client, "new tcp fail")
	client:send_buffer_size()

	--
	-- callback関数の定義
	--

	local on_shutdown = function()
		is_connect = false
		client:close()
	end

	local on_read_start = function(status, buf)
		assert(not status, status)
		if buf then
			resultbuf = resultbuf .. buf
		else
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

	local waiting = function()
		return not is_connect
	end
	vim.wait(1000, waiting)
	M.result = split(resultbuf, nil)
end


return M
