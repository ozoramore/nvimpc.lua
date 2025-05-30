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
		for k, v in string.gmatch(s, "(.+): (.+)") do
			t[k] = v
		end
	end
	return t
end

M.devide = function(tbl)
	local rp, marker, id = 0, 1, 0
	return function()
		local _arr = {}
		while rp < #tbl do
			rp = rp + 1
			if string.find(tbl[rp], "Pos:") then
				id = id + 1
				local t = M.parse(table.move(tbl, marker, rp, 1, _arr))
				marker = rp
				return id, t
			end
		end
		return nil
	end
end


return M
