local rxi_json = require("vkbridge.helpers.json")
local mock = require("vkbridge.helpers.mock")
local helper = require("vkbridge.helpers.helper")

--
-- HELPERS
--

local M = {vkbridge_ready = false, leaderboards_ready = false, payments_ready = false, player_ready = false, banner_ready = false}

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
end

function M.send(name, data, callback)
    assert(type(name) == "string")
    assert(type(callback) == "function")

    vkbridge_private.bridge_send(helper.wrap_for_promise(callback), name, data and rxi_json.encode(data) or nil)
end

return M
