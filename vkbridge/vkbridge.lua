local rxi_json = require("vkbridge.helpers.json")
local mock = require("vkbridge.helpers.mock")
local helper = require("vkbridge.helpers.helper")
local listeners = require("vkbridge.helpers.listeners")

--
-- HELPERS
--

local M = {vkbridge_ready = false}

local init_callback = nil

local function call_init_callback(self, err)
    if init_callback then
        local cb = init_callback
        init_callback = nil

        local ok, cb_err = pcall(cb, self, err)
        if not ok then
            print(cb_err)
        end
    end
end

local function init_listener(self, cb_id, message_id, message)
    if message_id == "init" then
        M.vkbridge_ready = true
        call_init_callback(self)
    elseif message_id == "error" then
        print("VkBridge couldn't be initialized.")
        call_init_callback(self, message)
    end

    vkbridge_private.remove_listener(init_listener)
end

local function on_any_event(self, cb_id, message_id, message)
    listeners.invoke(self, message)
end

--
-- PUBLIC API
--

---Initialize the Vk Bridge
---@param callback function
function M.init(callback)
    if not vkbridge_private then
        print("VkBridge is only available on the HTML5 platform. You will use the mocked version that is suitable only for testing.")
        mock.enable()
    end

    assert(type(callback) == "function")

    if M.vkbridge_ready then
        print("VkBridge is already initialized.")
        helper.async_call(callback)
        return
    end

    init_callback = callback
    vkbridge_private.add_listener(helper.VKBRIDGE_INIT_ID, init_listener)
    vkbridge_private.add_listener(helper.VKBRIDGE_SUBSCRIBE_ID, on_any_event)
    vkbridge_private.init_callbacks()
end

function M.send(name, data, callback)
    assert(type(name) == "string")
    assert(type(callback) == "function")

    vkbridge_private.send(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end), name, data and rxi_json.encode(data) or nil)
end

function M.subscribe(callback)
    assert(type(callback) == "function")

    listeners.add_listener(callback)
end

function M.unsubscribe(callback)
    assert(type(callback) == "function")

    listeners.remove_listener(callback)
end

function M.supports(name)
    assert(type(name) == "string")

    vkbridge_private.supports(name)
end

function M.is_webview()
    return vkbridge_private.is_webview()
end

function M.is_standalone()
    return vkbridge_private.is_standalone()
end

function M.is_iframe()
    return vkbridge_private.is_iframe()
end

function M.is_embedded()
    return vkbridge_private.is_embedded()
end

return M
