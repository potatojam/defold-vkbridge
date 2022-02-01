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
M.STOTAGE_SET = "VKWebAppStorageSet"
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

function M.send(name, data, callback)
    assert(type(name) == "string")
    assert(type(callback) == "function")

    vkbridge_private.send(helper.wrap_for_promise(function(self, message_id, result)
        if result then
            result = rxi_json.decode(result)
        end
        if message_id == "error" then
            callback(self, result)
        else
            callback(self, nil, result)
        end
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

function M.show_interstitial(callback)
    M.send(M.SHOW_NATIVE_ADS, {ad_format = "interstitial"}, callback)
end

function M.show_rewarded(use_waterfall, callback)
    M.send(M.SHOW_NATIVE_ADS, {ad_format = "reward", use_waterfall = use_waterfall}, callback)
end

return M
