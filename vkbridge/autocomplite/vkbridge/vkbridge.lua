---@class vkbridge
local vkbridge = {}
---Initialize the Vk Bridge
---@param callback function
function vkbridge.init(callback)
end

---Sends a message to native client and returns the object with response data
---@param name string The VK Bridge method
---@param data table|nil `optional` Message data object
---@param callback function `optional` callback with response data `function(self, err, data)`. If successful: `err = nil`.
function vkbridge.send(name, data, callback)
end

---Subscribes a function to events listening
---@param callback function
function vkbridge.subscribe(callback)
end

---Unsubscribes a function from events listening
---@param callback function
function vkbridge.unsubscribe(callback)
end

---Checks if an event is available on the current device
---@param name string The VK Bridge method
---@return boolean
function vkbridge.supports(name)
end

---Returns `true` if VK Bridge is running in mobile app, or `false` if not
---@return boolean
function vkbridge.is_webview()
end

---Returns `true` if VK Bridge is running in standalone app, or `false` if not
---@return boolean
function vkbridge.is_standalone()
end

---Returns `true` if VK Bridge is running in iframe, or `false` if not
---@return boolean
function vkbridge.is_iframe()
end

---Returns `true` if VK Bridge is running in embedded app, or `false` if not
---@return boolean
function vkbridge.is_embedded()
end

---Check if there is the interstitial ad available to serve
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function vkbridge.check_interstitial(callback)
end

---Show interstitial ads
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function vkbridge.show_interstitial(callback)
end

---Check if there is the rewarded ad available to serve
---@param use_waterfall boolean|nil Whether to use the mechanism for displaying interstitial advertising in the absence of rewarded video.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function vkbridge.check_rewarded(use_waterfall, callback)
end

---Show rewarded ads
---@param use_waterfall boolean|nil Whether to use the mechanism for displaying interstitial advertising in the absence of rewarded video.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function vkbridge.show_rewarded(use_waterfall, callback)
end

---Set the value of the variable whose name is passed in the `key` parameter. `Key` life is 1 year.
---@param key string Key name, [a-zA-Z_\-0-9]. The maximum length is 100 characters.
---@param value string The value of the variable. Only the first 4096 bytes are stored.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function vkbridge.storage_set(key, value, callback)
end

---Return the values of the variables.
---@param keys table|string Names of keys or key [a-zA-Z_\-0-9]. Can be a table or a string
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function vkbridge.storage_get(keys, callback)
end

---Return the names of all variables.
---@param count number The number of variable names to get information about.
---@param offset number|nil The offset required to select a particular subset of variable names.
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function vkbridge.storage_get_keys(count, offset, callback)
end

---Allows you to get basic data about the profile of the user who launched the application
---@param callback function callback with response data `function(self, err, data)`. If successful: `err = nil`.
function vkbridge.get_user_info(callback)
end

return vkbridge
