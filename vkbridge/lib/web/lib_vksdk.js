var LibVkBridge = {
    $VkBridgeLibrary: {
        _vkBridge: null,
        _lb: null,
        _payments: null,
        _player: null,
        _context: null,

        _callback_object: null,
        _callback_string: null,
        _callback_empty: null,
        _callback_number: null,
        _callback_bool: null,

        toErrStr: function (err) {
            return err + "";
        },

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
                if (cb_id == 0 && message_id == "init") {
                    VkBridgeLibrary._vkBridge = message;
                    message = undefined;
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
                if (typeof VkBridgeLibrary_MsgQueue !== "undefined") {
                    VkBridgeLibrary_MsgQueue.push([cb_id, message_id, message]);
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

        while (typeof VkBridgeLibrary_MsgQueue !== "undefined" && VkBridgeLibrary_MsgQueue.length) {
            var m = VkBridgeLibrary_MsgQueue.shift();
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

    VkBridgeLibrary_Send: function (cb_id, name, params) {
        var self = VkBridgeLibrary;
        try {
            var json_params = undefined;
            if (params) {
                json_params = self.parseJson(UTF8ToString(params));
            }
            var method = UTF8ToString(name)
            console.log(method, json_params)
            self._vkBridge.send(method, json_params)
                .then((result) => {
                    if (result) {
                        self.send(cb_id, null, JSON.stringify(result));
                    } else {
                        self.send(cb_id);
                    }

                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },
};

autoAddDeps(LibVkBridge, "$VkBridgeLibrary");
mergeInto(LibraryManager.library, LibVkBridge);
