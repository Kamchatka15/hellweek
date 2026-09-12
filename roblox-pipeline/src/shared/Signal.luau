--!strict
-- Signal — minimal pure-Lua signal.
--
-- Deliberately not a BindableEvent: Bindables deep-copy their payloads across the
-- boundary, so a table sent through one is no longer the table you sent. Engine
-- services pass profiles and player objects around by reference.

local Signal = {}
Signal.__index = Signal

export type Connection = { disconnect: (Connection) -> () }

function Signal.new()
	return setmetatable({ _handlers = {} }, Signal)
end

function Signal:connect(fn: (...any) -> ()): Connection
	local handlers = self._handlers
	table.insert(handlers, fn)
	return {
		disconnect = function()
			local index = table.find(handlers, fn)
			if index then
				table.remove(handlers, index)
			end
		end,
	}
end

function Signal:fire(...: any)
	-- Copy first: a handler is allowed to disconnect during dispatch.
	local snapshot = table.clone(self._handlers)
	for _, fn in snapshot do
		local ok, err = pcall(fn, ...)
		if not ok then
			warn(`[Signal] handler error: {err}`)
		end
	end
end

return Signal
