local rxi_json = require("vkbridge.helpers.json")
local helper = require("vkbridge.helpers.helper")
local events = require("vkbridge.events")

local M = {listeners = {}}

local storage = {}

--
--
--

function M.vk_send(cb_id, message_id, message)
    timer.delay(0.001, false, function(self)
        local count = #M.listeners
        for i = count, 1, -1 do
            local listener = M.listeners[i]
            if listener.only_id == cb_id then
                listener.func(self, cb_id, message_id, message)
            end
        end
    end)
end

function M.add_listener(cb_id, listener)
    table.insert(M.listeners, {only_id = cb_id, func = listener})
end

function M.remove_listener(listener)
    local count = #M.listeners
    for i = count, 1, -1 do
        local listener = M.listeners[i]
        if listener.func == listener then
            table.remove(M.listeners, i)
            break
        end
    end
end

function M.send(cb_id, message_id, message)
    if message_id == events.SHOW_NATIVE_ADS or message_id == events.CHECK_NATIVE_ADS then
        M.vk_send(cb_id, nil, rxi_json.encode({result = true}))
    elseif message_id == events.STORAGE_SET then
        local data = rxi_json.decode(message)
        storage[data.key] = data.value
        M.vk_send(cb_id, nil, rxi_json.encode({result = true}))
    elseif message_id == events.STORAGE_GET then
        local data = rxi_json.decode(message)
        local ex_data = {}
        for i, key in ipairs(data.keys) do
            local obj = {}
            obj.key = key
            obj.value = storage[key] or ""
            table.insert(ex_data, obj)
        end
        M.vk_send(cb_id, nil, rxi_json.encode({keys = ex_data}))
    elseif message_id == events.STORAGE_GET_KEYS then
        local data = rxi_json.decode(message)
        local offset = data.offset or 0
        local count = data.count or 0
        local ex_data = {}
        local i = 0
        for key, value in pairs(storage) do
            i = i + 1
            if i > offset + count then
                break
            end
            if i > offset then
                table.insert(ex_data, key)
            end
        end
        M.vk_send(cb_id, nil, rxi_json.encode({keys = ex_data}))
    elseif message_id == events.GET_USER_INFO then
        local data = {
            id = 2314852,
            first_name = "Mock",
            last_name = "Mockovish",
            sex = 1,
            city = {id = 2, title = "Saint Petersburg"},
            country = {id = 1, title = "Russia"},
            bdate = "10.4.1990",
            photo_100 = "https://pp.userapi.com/c836333/v836333553/5b138/2eWBOuj5A4g.jpg]",
            photo_200 = "https://pp.userapi.com/c836333/v836333553/5b137/tEJNQNigU80.jpg]",
            timezone = 3
        }
        M.vk_send(cb_id, nil, rxi_json.encode(data))
    else
        M.vk_send(cb_id, nil, message)
    end
end

function M.init_callbacks()
end

function M.supports(name)
    for key, e_name in pairs(events) do
        if name == e_name then
            return true
        end
    end
    return false
end

function M.is_webview()
    return false
end

function M.is_standalone()
    return true
end

function M.is_iframe()
    return false
end

function M.is_embedded()
    return false
end

return {
    enable = function()
        if not vkbridge_private then
            vkbridge_private = M

            M.vk_send(helper.VKBRIDGE_INIT_ID, "init")
        end
    end
}
