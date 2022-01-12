var LibVkSDK = {
    $VkSDKLibrary: {
        _ysdk: null,
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
            if (VkSDKLibrary._callback_object) {
                // 0 and 1 are reserved IDs
                if (cb_id == 0 && message_id == "init") {
                    VkSDKLibrary._ysdk = message;
                    message = undefined;
                }

                var cmsg_id = 0;
                if (typeof message_id === "string") {
                    cmsg_id = allocate(intArrayFromString(message_id), "i8", ALLOC_NORMAL);
                }
                switch (typeof message) {
                    case "undefined":
                        { { { makeDynCall("vii", "VkSDKLibrary._callback_empty") } } } (cb_id, cmsg_id);
                        break;
                    case "number":
                        { { { makeDynCall("viif", "VkSDKLibrary._callback_number") } } } (cb_id, cmsg_id, message);
                        break;
                    case "string":
                        var msg = allocate(intArrayFromString(message), "i8", ALLOC_NORMAL);
                        { { { makeDynCall("viii", "VkSDKLibrary._callback_string") } } } (cb_id, cmsg_id, msg);
                        Module._free(msg);
                        break;
                    case "object":
                        var msg = JSON.stringify(message);
                        msg = allocate(intArrayFromString(msg), "i8", ALLOC_NORMAL);
                        { { { makeDynCall("viii", "VkSDKLibrary._callback_object") } } } (cb_id, cmsg_id, msg);
                        Module._free(msg);
                        break;
                    case "boolean":
                        var msg = message ? 1 : 0;
                        { { { makeDynCall("viii", "VkSDKLibrary._callback_bool") } } } (cb_id, cmsg_id, msg);
                        break;
                    default:
                        console.warn("Unsupported message format: " + typeof message);
                }
                if (cmsg_id) {
                    Module._free(cmsg_id);
                }
            } else {
                // console.warn("You didn't set callback for VkSDKLibrary");
                if (typeof VkSDKLibrary_MsgQueue !== "undefined") {
                    VkSDKLibrary_MsgQueue.push([cb_id, message_id, message]);
                }
            }
        },

        delaySend: function (cb_id, message_id, message) {
            setTimeout(() => {
                VkSDKLibrary.send(cb_id, message_id, message);
            }, 0);
        },
    },

    VkSDKLibrary_RegisterCallbacks: function (
        callback_object,
        callback_string,
        callback_empty,
        callback_number,
        callback_bool
    ) {
        var self = VkSDKLibrary;

        self._callback_object = callback_object;
        self._callback_string = callback_string;
        self._callback_empty = callback_empty;
        self._callback_number = callback_number;
        self._callback_bool = callback_bool;

        while (typeof VkSDKLibrary_MsgQueue !== "undefined" && VkSDKLibrary_MsgQueue.length) {
            var m = VkSDKLibrary_MsgQueue.shift();
            self.send(m[0], m[1], m[2]);
        }
    },

    VkSDKLibrary_RemoveCallbacks: function () {
        var self = VkSDKLibrary;

        self._callback_object = null;
        self._callback_string = null;
        self._callback_empty = null;
        self._callback_number = null;
        self._callback_bool = null;
    },

};

autoAddDeps(LibVkSDK, "$VkSDKLibrary");
mergeInto(LibraryManager.library, LibVkSDK);