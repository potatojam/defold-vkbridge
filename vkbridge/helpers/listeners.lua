local M = {}

local listeners = {}

function M.add_listener(callback)
    for i, listener in ipairs(listeners) do
        if listener == callback then
            return
        end
    end
    table.insert(listeners, callback)
end

function M.remove_listener(callback)
    for i, listener in ipairs(listeners) do
        if listener == callback then
            table.remove(listeners, i)
            return
        end
    end
end

function M.invoke(self, response)
    for i, listener in ipairs(listeners) do
        listener(self, response)
    end
end

return M
