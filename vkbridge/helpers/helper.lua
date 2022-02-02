local M = {}

-- constants
M.VKBRIDGE_INIT_ID = 0
M.VKBRIDGE_SUBSCRIBE_ID = 1

-- private
local cb_id_counter = 3
local function next_cb_id()
    local id = cb_id_counter
    cb_id_counter = (cb_id_counter + 1) % 2147483647
    if cb_id_counter == 0 or cb_id_counter == 1 then
        cb_id_counter = cb_id_counter + 1
    end
    return id
end

function M.wrap_for_promise(then_callback)
    local cb_id = next_cb_id()
    local listener
    listener = function(self, _cb_id, message_id, message)
        vkbridge_private.remove_listener(listener)
        then_callback(self, message_id, message)
    end

    vkbridge_private.add_listener(cb_id, listener)
    return cb_id
end

function M.async_call(cb)
    if cb then
        timer.delay(0, false, function(self)
            cb(self)
        end)
    end
end

return M
