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

	local family_type = ""
	if M.config.isv6 then family_type = "inetv6" else family_type = 'inet' end

	local info = vim.uv.getaddrinfo(M.config.host, nil, { family = family_type })
	M.config.addr = info[1].addr
end

M.command = function(data, callback)
	local result_buffer = ""
	local client = {}

	local on_close = function(_)
		if callback and (#result_buffer > 0) then
			callback(util.split(result_buffer, '\n'))
		end
	end

	local check_message = function(buf)
		if not buf then return client:close(on_close) end
		result_buffer = result_buffer .. buf
		if string.len(result_buffer) < 4 then return end
		if string.sub(result_buffer, -4) ~= "\nOK\n" then return end
		client:write('close\n')
		client:close(on_close)
	end

	local on_read_start = function(status, buf)
		if status then
			client:close(on_close)
		else
			check_message(buf)
		end
	end

	local on_write = function(status)
		if status then
			client:close(on_close)
		else
			client:read_start(on_read_start)
		end
	end

	local on_connect = function(status)
		if status then
			client:close(on_close)
		else
			client:write(data .. '\n', on_write)
		end
	end

	client = vim.uv.new_tcp()
	if not client then return false end
	client:connect(M.config.addr, M.config.port, on_connect)
	return true
end

return M
