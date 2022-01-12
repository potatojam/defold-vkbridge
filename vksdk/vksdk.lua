local rxi_json = require("vksdk.helpers.json")
local mock = require("vksdk.helpers.mock")
local helper = require("vksdk.helpers.helper")

--
-- HELPERS
--

local M = {vksdk_ready = false, leaderboards_ready = false, payments_ready = false, player_ready = false, banner_ready = false}

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
        M.vksdk_ready = true
        call_init_callback(self)
    elseif message_id == "error" then
        print("VkSDK couldn't be initialized.")
        call_init_callback(self, message)
    end

    vksdk_private.remove_listener(init_listener)
end

--
-- PUBLIC API
--

--- Initialize the Yandex.Games SDK
-- @tparam function callback
function M.init(callback)
    if not vksdk_private then
        print("VkSDK is only available on the HTML5 platform. You will use the mocked version that is suitable only for testing.")
        mock.enable()
    end

    assert(type(callback) == "function")

    if M.vksdk_ready then
        print("VkSDK is already initialized.")
        helper.async_call(callback)
        return
    end

    init_callback = callback
    vksdk_private.add_listener(helper.VKSDK_INIT_ID, init_listener)
end

return M
