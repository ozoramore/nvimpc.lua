local M = {}
M.__index = M

function M.new() return setmetatable({}, M) end

function M:set(s)
	self.txt = s; return self
end

function M:get() return self.txt end

function M:tr(a, b)
	self.txt = string.gsub(self.txt, a, b); return self
end

function M:srr(a)
	self.txt = a .. self.txt .. a; return self
end

return M
