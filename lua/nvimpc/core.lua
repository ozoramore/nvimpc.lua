local M = {}
local util = require('nvimpc.util')

M.config = {
	host = 'localhost',
	addr = nil,
	port = 6600,
	password = nil,
	isv6 = false,
}

M.setup = function(opts)
	M.config = vim.tbl_deep_extend('force', M.config, opts or {})
	if M.config.addr then return end
	local family = (function(isv6) if isv6 then return 'inetv6' else return 'inet' end end)
	local callback = function(_, info) M.config.addr = info[1].addr end
	vim.uv.getaddrinfo(M.config.host, nil, { family = family(M.config.isv6) }, callback)
end

local close = function(cl, cb)
	local w_cb = function(_) cl:close(cb) end
	cl:write('close\n', w_cb)
end

local cb_if = function(cl, ret, cb, buf)
	cb = cb or function(_) end
	if ret then close(cl, function(_) cb(util.split(buf, '\n')) end) end
	return ret
end

local chk_fail = function(cl, ret, msg)
	if ret then close(cl, function(_) error(msg) end) end
	return ret
end

local read_start = function(cl, cb)
	local result = ''
	local callback = function(st, buf)
		result = result .. (buf or '')
		local is_err = st or (buf and string.sub(buf, 1, 3) == 'ACK')
		local is_eom = not buf or string.sub(result .. buf, -4) == '\nOK\n'
		if not chk_fail(cl, is_err, st or buf) then cb_if(cl, is_eom, cb, result) end
	end
	cl:read_start(callback)
end

local write = function(cl, data, cb)
	local callback = function(st) if not chk_fail(cl, st, st) then read_start(cl, cb) end end
	cl:write(data .. '\n', callback)
end

local connect = function(cl, data, cb)
	local callback = function(st) if not chk_fail(cl, st, st) then write(cl, data, cb) end end
	cl:connect(M.config.addr, M.config.port, callback)
end

M.exec = function(data, cb)
	local client = vim.uv.new_tcp()
	if not client then return end
	connect(client, data, cb)
end

return M
