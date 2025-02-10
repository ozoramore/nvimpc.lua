local uv = vim.uv
local M = {}

M.config = {
	host = "localhost",
	addr = nil,
	port = 6600,
	password = nil,
	isv6 = false,
}

M.result = {}
M.connection = false

local resultbuf = ""

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

local connect = function(host, port, data)
	local client = uv.new_tcp()
	assert(client, "new tcp fail")
	local writebuf = data .. "\nclose\n"
	resultbuf = ""
	M.connection = true
	client:send_buffer_size()
	client:connect(host, port, function(status)
		assert(not status, status)
		client:write(writebuf, function(status_write)
			assert(not status_write, status_write)
			client:read_start(function(status_read, readbuf)
				assert(not status_read, status_read)
				if readbuf then
					resultbuf = resultbuf .. readbuf
				else
					client:shutdown(function()
						M.connection = false
						client:close()
					end)
				end
			end)
		end)
	end)
end

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	local family_type = "inet"
	if M.config.isv6 then
		family_type = "inetv6"
	end
	M.config.addr = M.config.addr or uv.getaddrinfo(M.config.host, nil, { family = family_type })[1].addr
end

M.command = function(opts)
	connect(M.config.addr, M.config.port, opts)
	vim.wait(1000, function()
		return not M.connection
	end)
	M.result = split(resultbuf,nil)
end

return M
