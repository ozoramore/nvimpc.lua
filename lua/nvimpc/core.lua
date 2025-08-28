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
	if M.config.addr then return end
	local family_type = (function(isv6) if isv6 then return "inetv6" else return 'inet' end end)()
	vim.uv.getaddrinfo(M.config.host, nil, { family = family_type }, function(_, info) M.config.addr = info[1].addr end)
end

local cb_if = function(client, is_success, cb, buf)
	if not is_success then return false end
	cb = cb or function(_) end
	client:write('close\n', function(_) client:close(function(_) cb(util.split(buf, '\n')) end) end)
	return true
end

local check_pass = function(client, ret, message)
	if not ret then return true end
	client:write('close\n', function(_) client:close(function(_) error(message) end) end)
	return false
end

local read_start = function(client, cb)
	local result = ""
	client:read_start(function(status, buf)
		if not check_pass(client, status, status) then return end
		if cb_if(client, not buf, cb, result) then return end
		if not check_pass(client, string.sub(buf, 1, 3) == "ACK", buf) then return end
		result = result .. buf
		cb_if(client, string.sub(result, -4) == "\nOK\n", cb, result)
	end)
end

local write = function(client, data, cb)
	client:write(data .. '\n',
		function(status) if check_pass(client, status, status) then read_start(client, cb) end end)
end

local connect = function(client, data, cb)
	if not client then return end
	client:connect(M.config.addr, M.config.port,
		function(status) if check_pass(client, status, status) then write(client, data, cb) end end)
end

M.command = function(data, cb)
	connect(vim.uv.new_tcp(), data, cb)
end

return M
