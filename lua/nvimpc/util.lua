local M = {}

M.split = function(str, ts)
	local t = {}
	local ptn = '([^' .. (ts or '\n') .. ']+)'
	for s in string.gmatch(str, ptn) do table.insert(t, s) end
	return t
end

M.parse = function(array)
	local t = {}
	for _, s in pairs(array) do
		for k, v in string.gmatch(s, '(.+): (.+)') do t[k] = v end
	end
	return t
end

local devider = function(tbl, rp, marker, id)
	rp = rp + 1
	if not string.find(tbl[rp], 'Id:') then return nil, rp, marker, id end
	local t = table.move(tbl, marker, rp, 1, {})
	return M.parse(t), rp, rp, id + 1
end

M.devide = function(tbl)
	local t, rp, marker, id = nil, 0, 1, 0
	return function()
		while rp < #tbl do
			t, rp, marker, id = devider(tbl, rp, marker, id)
			if t then return id, t end
		end
		return nil
	end
end


return M
