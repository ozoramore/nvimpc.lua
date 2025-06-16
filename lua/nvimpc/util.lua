local M = {}

M.split = function(str, ts)
	local t, i = {}, 1
	ts = ts or "\n"
	for s in string.gmatch(str, "([^" .. ts .. "]+)") do
		t[i] = s
		i = i + 1
	end
	return t
end

M.parse = function(array)
	local t = {}
	for _, s in pairs(array) do
		for k, v in string.gmatch(s, "(.+): (.+)") do t[k] = v end
	end
	return t
end

local devider = function(tbl, rp, marker, id)
	rp = rp + 1
	if not string.find(tbl[rp], "Id:") then return nil, rp, marker, id end
	local t = M.parse(table.move(tbl, marker, rp, 1, {}))
	return t, rp, rp, (id + 1)
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
