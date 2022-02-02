local rxi_json = require("vkbridge.helpers.json")
local mock = require("vkbridge.helpers.mock")
local helper = require("vkbridge.helpers.helper")
local listeners = require("vkbridge.helpers.listeners")

--
-- HELPERS
--

local M = {vkbridge_ready = false}

M.INIT = "VKWebAppInit"
M.GET_COMMUNITY_AUTH_TOKEN = "VKWebAppGetCommunityAuthToken"
M.ADD_TO_COMMUNITY = "VKWebAppAddToCommunity"
M.ADD_TO_HOME_SCREEN_INFO = "VKWebAppAddToHomeScreenInfo"
M.CLOSE = "VKWebAppClose"
M.COPY_TEXT = "VKWebAppCopyText"
M.CREATE_HASH = "VKWebAppCreateHash"
M.GET_USER_INFO = "VKWebAppGetUserInfo"
M.SET_LOCATION = "VKWebAppSetLocation"
M.SEND_TO_CLIENT = "VKWebAppSendToClient"
M.GET_CLIENT_VERSION = "VKWebAppGetClientVersion"
M.GET_PHONE_NUMBER = "VKWebAppGetPhoneNumber"
M.GET_EMAIL = "VKWebAppGetEmail"
M.GET_GROUP_INFO = "VKWebAppGetGroupInfo"
M.GET_GEODATA = "VKWebAppGetGeodata"
M.GET_COMMUNITY_TOKEN = "VKWebAppGetCommunityToken"
M.GET_CONFIG = "VKWebAppGetConfig"
M.GET_LAUNCH_PARAMS = "VKWebAppGetLaunchParams"
M.SET_TITLE = "VKWebAppSetTitle"
M.GET_AUTH_TOKEN = "VKWebAppGetAuthToken"
M.CALL_API_METHOD = "VKWebAppCallAPIMethod"
M.JOIN_GROUP = "VKWebAppJoinGroup"
M.LEAVE_GROUP = "VKWebAppLeaveGroup"
M.ALLOW_MESSAGES_FROM_GROUP = "VKWebAppAllowMessagesFromGroup"
M.DENY_NOTIFICATIONS = "VKWebAppDenyNotifications"
M.ALLOW_NOTIFICATIONS = "VKWebAppAllowNotifications"
M.OPEN_PAY_FORM = "VKWebAppOpenPayForm"
M.OPEN_APP = "VKWebAppOpenApp"
M.SHARE = "VKWebAppShare"
M.SHOW_WALL_POST_BOX = "VKWebAppShowWallPostBox"
M.SCROLL = "VKWebAppScroll"
M.SHOW_ORDER_BOX = "VKWebAppShowOrderBox"
M.SHOW_LEADER_BOARD_BOX = "VKWebAppShowLeaderBoardBox"
M.SHOW_INVITE_BOX = "VKWebAppShowInviteBox"
M.SHOW_REQUEST_BOX = "VKWebAppShowRequestBox"
M.ADD_TO_FAVORITES = "VKWebAppAddToFavorites"
M.SHOW_COMMUNITY_WIDGET_PREVIEW_BOX = "VKWebAppShowCommunityWidgetPreviewBox"
M.SHOW_STORY_BOX = "VKWebAppShowStoryBox"
M.STORAGE_GET = "VKWebAppStorageGet"
M.STORAGE_GET_KEYS = "VKWebAppStorageGetKeys"
M.STORAGE_SET = "VKWebAppStorageSet"
M.FLASH_GET_INFO = "VKWebAppFlashGetInfo"
M.SUBSCRIBE_STORY_APP = "VKWebAppSubscribeStoryApp"
M.OPEN_WALL_POST = "VKWebAppOpenWallPost"
M.CHECK_ALLOWED_SCOPES = "VKWebAppCheckAllowedScopes"
M.CHECK_NATIVE_ADS = "VKWebAppCheckNativeAds"
M.SHOW_NATIVE_ADS = "VKWebAppShowNativeAds"
M.RETARGETING_PIXEL = "VKWebAppRetargetingPixel"
M.CONVERSION_HIT = "VKWebAppConversionHit"
M.RESUZE_WINDOW = "VKWebAppResizeWindow"
M.ADD_TO_MENU = "VKWebAppAddToMenu"
M.SHOW_SUBSCRIPTION_BOX = "VKWebAppShowSubscriptionBox"
M.SHOW_INSTALL_PUSH_BOX = "VKWebAppShowInstallPushBox"
M.GET_FRIENDS = "VKWebAppGetFriends"
M.SHOW_IMAGES = "VKWebAppShowImages"

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

---Sends a message to native client and returns the object with response data
---@param name string The VK Bridge method
---@param data table|nil `optional` Message data object
---@param callback function `optional` callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.send(name, data, callback)
    assert(type(name) == "string", "The VK Bridge method must be set.")

    vkbridge_private.send(helper.wrap_for_promise(function(self, message_id, result)
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
    end), name, data and rxi_json.encode(data) or nil)
end

---Subscribes a function to events listening
---@param callback function
function M.subscribe(callback)
    assert(type(callback) == "function", "Not the correct callback.")

    listeners.add_listener(callback)
end

---Unsubscribes a function from events listening
---@param callback function
function M.unsubscribe(callback)
    assert(type(callback) == "function", "Not the correct callback.")

    listeners.remove_listener(callback)
end

---Checks if an event is available on the current device
---@param name string The VK Bridge method
function M.supports(name)
    assert(type(name) == "string", "The VK Bridge method must be set.")

    vkbridge_private.supports(name)
end

---Returns `true` if VK Bridge is running in mobile app, or `false` if not
---@return boolean
function M.is_webview()
    return vkbridge_private.is_webview()
end

---Returns `true` if VK Bridge is running in standalone app, or `false` if not
---@return boolean
function M.is_standalone()
    return vkbridge_private.is_standalone()
end

---Returns `true` if VK Bridge is running in iframe, or `false` if not
---@return boolean
function M.is_iframe()
    return vkbridge_private.is_iframe()
end

---Returns `true` if VK Bridge is running in embedded app, or `false` if not
---@return boolean
function M.is_embedded()
    return vkbridge_private.is_embedded()
end

---Check if there is the interstitial ad available to serve
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.check_interstitial(callback)
    M.send(M.CHECK_NATIVE_ADS, {ad_format = "interstitial"}, callback)
end

---Show interstitial ads
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.show_interstitial(callback)
    M.send(M.SHOW_NATIVE_ADS, {ad_format = "interstitial"}, callback)
end

---Check if there is the rewarded ad available to serve
---@param use_waterfall boolean|nil Whether to use the mechanism for displaying interstitial advertising in the absence of rewarded video.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.check_rewarded(use_waterfall, callback)
    M.send(M.CHECK_NATIVE_ADS, {ad_format = "interstitial", use_waterfall = use_waterfall}, callback)
end

---Show rewarded ads
---@param use_waterfall boolean|nil Whether to use the mechanism for displaying interstitial advertising in the absence of rewarded video.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.show_rewarded(use_waterfall, callback)
    M.send(M.SHOW_NATIVE_ADS, {ad_format = "reward", use_waterfall = use_waterfall}, callback)
end

---Set the value of the variable whose name is passed in the `key` parameter. `Key` life is 1 year.
---@param key string Key name, [a-zA-Z_\-0-9]. The maximum length is 100 characters.
---@param value string The value of the variable. Only the first 4096 bytes are stored.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.storage_set(key, value, callback)
    assert(type(key) == "string", "Wrong key format. Must be string.")
    assert(type(value) == "string", "Wrong value format. Must be string.")
    M.send(M.STORAGE_SET, {key = key, value = value}, callback)
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
    M.send(M.STORAGE_GET, {keys = keys}, callback)
end

---Return the names of all variables.
---@param count number The number of variable names to get information about.
---@param offset number|nil The offset required to select a particular subset of variable names.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function M.storage_get_keys(count, offset, callback)
    assert(type(count) == "number", "Wrong count format. Must be number.")
    M.send(M.STORAGE_GET_KEYS, {count = count, offset = offset}, callback)
end

return M
