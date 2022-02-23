local rxi_json = require("vkbridge.helpers.json")
local mock = require("vkbridge.helpers.mock")
local helper = require("vkbridge.helpers.helper")
local listeners = require("vkbridge.helpers.listeners")
local events = require("vkbridge.events")

--
-- HELPERS
--

local M = {}

M.vkbridge_ready = false
M.is_webview_ch = false
M.is_standalone_ch = false
M.is_iframe_ch = false
M.is_embedded_ch = false

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
        M.is_webview_ch = vkbridge_private.is_webview()
        M.is_standalone_ch = vkbridge_private.is_standalone()
        M.is_iframe_ch = vkbridge_private.is_iframe()
        M.is_embedded_ch = vkbridge_private.is_embedded()
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

local function auto_handle(callback)
    return helper.wrap_for_promise(function(self, message_id, result)
        if callback then
            if result then
                result = rxi_json.decode(result)
            end
            if message_id == "error" then
                callback(self, result)
            else
                callback(self, nil, result)
            end
        end
    end)
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

---Sends a message to native client and returns the object with response data
---@param name string The VK Bridge method
---@param data table|nil `optional` Message data object
---@param callback function `optional` callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.send(name, data, callback)
    assert(type(name) == "string", "The VK Bridge method must be set.")

    vkbridge_private.send(auto_handle(callback), name, data and rxi_json.encode(data) or nil)
end

---Subscribes a function to events listening
---@param fn function
function M.subscribe(fn)
    assert(type(fn) == "function", "Not the correct function.")

    listeners.add_listener(fn)
end

---Unsubscribes a function from events listening
---@param fn function
function M.unsubscribe(fn)
    assert(type(fn) == "function", "Not the correct function.")

    listeners.remove_listener(fn)
end

---Checks if an event is available on the current device
---@param name string The VK Bridge method
---@return boolean
function M.supports(name)
    assert(type(name) == "string", "The VK Bridge method must be set.")

    return vkbridge_private.supports(name)
end

---Returns `true` if VK Bridge is running in mobile app, or `false` if not
---@return boolean
function M.is_webview()
    return M.is_webview_ch
end

---Returns `true` if VK Bridge is running in standalone app, or `false` if not
---@return boolean
function M.is_standalone()
    return M.is_standalone_ch
end

---Returns `true` if VK Bridge is running in iframe, or `false` if not
---@return boolean
function M.is_iframe()
    return M.is_iframe_ch
end

---Returns `true` if VK Bridge is running in embedded app, or `false` if not
---@return boolean
function M.is_embedded()
    return M.is_embedded_ch
end

---Check if there is the interstitial ad available to serve
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.check_interstitial(callback)
    M.send(events.CHECK_NATIVE_ADS, {ad_format = "interstitial"}, callback)
end

---Show interstitial ads
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.show_interstitial(callback)
    M.send(events.SHOW_NATIVE_ADS, {ad_format = "interstitial"}, callback)
end

---Check if there is the rewarded ad available to serve
---@param use_waterfall boolean|nil Whether to use the mechanism for displaying interstitial advertising in the absence of rewarded video.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.check_rewarded(use_waterfall, callback)
    M.send(events.CHECK_NATIVE_ADS, {ad_format = "interstitial", use_waterfall = use_waterfall}, callback)
end

---Show rewarded ads
---@param use_waterfall boolean|nil Whether to use the mechanism for displaying interstitial advertising in the absence of rewarded video.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.show_rewarded(use_waterfall, callback)
    M.send(events.SHOW_NATIVE_ADS, {ad_format = "reward", use_waterfall = use_waterfall}, callback)
end

---Set the value of the variable whose name is passed in the `key` parameter. `Key` life is 1 year.
---@param key string Key name, [a-zA-Z_\-0-9]. The maximum length is 100 characters.
---@param value string The value of the variable. Only the first 4096 bytes are stored.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.storage_set(key, value, callback)
    assert(type(key) == "string", "Wrong key format. Must be string.")
    assert(type(value) == "string", "Wrong value format. Must be string.")
    M.send(events.STORAGE_SET, {key = key, value = value}, callback)
end

---Return the values of the variables.
---@param keys table|string Names of keys or key [a-zA-Z_\-0-9]. Can be a table or a string
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.storage_get(keys, callback)
    assert(type(keys) == "table" or type(keys) == "string", "Wrong keys format. Must be table or string.")
    assert(type(callback) == "function", "Not the correct callback.")
    if type(keys) == "string" then
        keys = {keys}
    end
    M.send(events.STORAGE_GET, {keys = keys}, callback)
end

---Return the names of all variables.
---@param count number The number of variable names to get information about.
---@param offset number|nil The offset required to select a particular subset of variable names.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.storage_get_keys(count, offset, callback)
    assert(type(count) == "number", "Wrong count format. Must be number.")
    M.send(events.STORAGE_GET_KEYS, {count = count, offset = offset}, callback)
end

---Allows you to get basic data about the profile of the user who launched the application
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.get_user_info(callback)
    assert(type(callback) == "function", "Not the correct callback.")
    M.send(events.GET_USER_INFO, nil, callback)
end

---Set WebView banner configs. Available for mobile only.
---@param position string Banner location. Can be `top` or `bottom`. Default `top`
---@param count number `optional` Number of banners in a column.
function M.set_wv_banner_configs(position, count)
    assert(M.is_webview() == true, "Webview is not available. Available for mobile only.")
    assert(position == nil or position == "top" or position == "bottom", "The position can only be \"top\" or \"bottom\".")
    vkbridge_private.set_wv_banner_configs(position or "top", count or 1)
end

---Load WebView banner. Available for mobile only.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.load_wv_banner(callback)
    assert(M.is_webview() == true, "Webview is not available. Available for mobile only.")
    vkbridge_private.load_wv_banner(auto_handle(callback))
end

---Unload WebView banner. Available for mobile only.
---@return boolean
function M.unload_wv_banner()
    assert(M.is_webview() == true, "Webview is not available. Available for mobile only.")
    return vkbridge_private.unload_wv_banner()
end

---Refresh WebView banner. Available for mobile only.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.refresh_wv_banner(callback)
    assert(M.is_webview() == true, "Webview is not available. Available for mobile only.")
    vkbridge_private.refresh_wv_banner(auto_handle(callback))
end

---Show WebView banner. Available for mobile only.
---@return boolean
function M.show_wv_banner()
    assert(M.is_webview() == true, "Webview is not available. Available for mobile only.")
    return vkbridge_private.show_wv_banner()
end

---Hide WebView banner. Returns `true` on success. Available for mobile only.
---@return boolean
function M.hide_wv_banner()
    assert(M.is_webview() == true, "Webview is not available. Available for mobile only.")
    return vkbridge_private.hide_wv_banner()
end

return M
