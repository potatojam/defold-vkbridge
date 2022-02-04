var LibVkBridge = {
    $VkBridgeLibrary: {
        _vkBridge: null,
        _callback_object: null,
        _callback_string: null,
        _callback_empty: null,
        _callback_number: null,
        _callback_bool: null,
        _wv_banner_configs: { position: "top", count: 1, scheme: "light" },

        parseJson: function (json) {
            try {
                return JSON.parse(json);
            } catch (e) {
                return null;
            }
        },

        send: function (cb_id, message_id, message) {
            if (VkBridgeLibrary._callback_object) {
                // 0 and 1 are reserved IDs
                if (cb_id == VkBridgeHelper.VKBRIDGE_INIT_ID && message_id == "init") {
                    VkBridgeLibrary._vkBridge = message;
                    message = undefined;
                } else if (cb_id == VkBridgeHelper.VKBRIDGE_SUBSCRIBE_ID && message_id == "subscribe") {
                    if (message && message.detail && message.detail.type === "VKWebAppUpdateConfig") {
                        VkBridgeLibrary._wv_banner_configs.scheme = message.detail.data.scheme.replace('vkcom_', '');
                    }
                }

                var cmsg_id = 0;
                if (typeof message_id === "string") {
                    cmsg_id = allocate(intArrayFromString(message_id), "i8", ALLOC_NORMAL);
                }
                switch (typeof message) {
                    case "undefined":
                        {{{ makeDynCall("vii", "VkBridgeLibrary._callback_empty") }}} (cb_id, cmsg_id);
                        break;
                    case "number":
                        {{{ makeDynCall("viif", "VkBridgeLibrary._callback_number") }}} (cb_id, cmsg_id, message);
                        break;
                    case "string":
                        var msg = allocate(intArrayFromString(message), "i8", ALLOC_NORMAL);
                        {{{ makeDynCall("viii", "VkBridgeLibrary._callback_string") }}} (cb_id, cmsg_id, msg);
                        Module._free(msg);
                        break;
                    case "object":
                        var msg = JSON.stringify(message);
                        msg = allocate(intArrayFromString(msg), "i8", ALLOC_NORMAL);
                        {{{ makeDynCall("viii", "VkBridgeLibrary._callback_object") }}} (cb_id, cmsg_id, msg);
                        Module._free(msg);
                        break;
                    case "boolean":
                        var msg = message ? 1 : 0;
                        {{{ makeDynCall("viii", "VkBridgeLibrary._callback_bool") }}} (cb_id, cmsg_id, msg);
                        break;
                    default:
                        console.warn("Unsupported message format: " + typeof message);
                }
                if (cmsg_id) {
                    Module._free(cmsg_id);
                }
            } else {
                // console.warn("You didn't set callback for VkBridgeLibrary");
                if (typeof VkBridgeHelper !== "undefined") {
                    VkBridgeHelper.msgQueue.push([cb_id, message_id, message]);
                }
            }
        },

        delaySend: function (cb_id, message_id, message) {
            setTimeout(() => {
                VkBridgeLibrary.send(cb_id, message_id, message);
            }, 0);
        },
    },

    VkBridgeLibrary_RegisterCallbacks: function (
        callback_object,
        callback_string,
        callback_empty,
        callback_number,
        callback_bool
    ) {
        var self = VkBridgeLibrary;

        self._callback_object = callback_object;
        self._callback_string = callback_string;
        self._callback_empty = callback_empty;
        self._callback_number = callback_number;
        self._callback_bool = callback_bool;

        while (typeof VkBridgeHelper !== "undefined" && VkBridgeHelper.msgQueue.length) {
            var m = VkBridgeHelper.msgQueue.shift();
            self.send(m[0], m[1], m[2]);
        }
    },

    VkBridgeLibrary_RemoveCallbacks: function () {
        var self = VkBridgeLibrary;

        self._callback_object = null;
        self._callback_string = null;
        self._callback_empty = null;
        self._callback_number = null;
        self._callback_bool = null;
    },

    VkBridgeLibrary_Init: function () {
        if (typeof VkBridgeHelper !== "undefined" && !VkBridgeHelper.autoInit) {
            VkBridgeHelper.init();
        }
    },

    VkBridgeLibrary_Send: function (cb_id, name, params) {
        var self = VkBridgeLibrary;
        try {
            var json_params = undefined;
            if (params) {
                json_params = self.parseJson(UTF8ToString(params));
            }
            var method = UTF8ToString(name);
            self._vkBridge.send(method, json_params)
                .then((result) => {
                    if (result) {
                        self.send(cb_id, null, JSON.stringify(result));
                    } else {
                        self.send(cb_id);
                    }
                })
                .catch((err) => {
                    self.send(cb_id, "error", VkBridgeHelper.conver_error(err));
                });
        } catch (err) {
            self.delaySend(cb_id, "error", VkBridgeHelper.conver_error(err));
        }
    },

    VkBridgeLibrary_SetWebViewBannerConfigs: function (position, count) {
        var self = VkBridgeLibrary;
        self._wv_banner_configs.position = UTF8ToString(position);
        self._wv_banner_configs.count = count;
    },

    VkBridgeLibrary_ShowWebViewBanner: async function (cb_id) {
        var self = VkBridgeLibrary;
        try {
            if (self._wv_banner_configs.count === 0) {
                self.send(cb_id, null, JSON.stringify({ count: 0, result: true }));
            } else {
                var values = [];
                var value;
                for (let i = 0; i < self._wv_banner_configs.count; i++) {
                    value = await self._vkBridge.send("VKWebAppGetAds", {})
                    values.push(value);
                }
                VkBridgeHelper.app.showBanner(values, self._wv_banner_configs.position, self._wv_banner_configs.scheme);
                self.send(cb_id, null, JSON.stringify({ result: true }));
            }
        } catch (err) {
            self.delaySend(cb_id, "error", VkBridgeHelper.conver_error(err));
        }
    },

    VkBridgeLibrary_HideWebViewBanner: function () {
        var result = true;
        try {
            VkBridgeHelper.app.hideBanner();
        } catch (err) {
            result = false;
            // TODO handle error
        }
        return result;
    },

    VkBridgeLibrary_Supports: function (name) {
        var method = UTF8ToString(name);
        var result = VkBridgeLibrary._vkBridge.supports(method);
        return result
    },

    VkBridgeLibrary_isWebView: function () {
        return VkBridgeLibrary._vkBridge.isWebView();
    },

    VkBridgeLibrary_isStandalone: function () {
        return VkBridgeLibrary._vkBridge.isStandalone();
    },

    VkBridgeLibrary_isEmbedded: function () {
        return VkBridgeLibrary._vkBridge.isEmbedded();
    },

    VkBridgeLibrary_isIframe: function () {
        return VkBridgeLibrary._vkBridge.isIframe();
    },
};

autoAddDeps(LibVkBridge, "$VkBridgeLibrary");
mergeInto(LibraryManager.library, LibVkBridge);
