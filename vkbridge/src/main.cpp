// Extension lib defines
#define LIB_NAME "VkBridge"
#define MODULE_NAME "VkBridge"
#define MODULE_PRIVATE_NAME "vkbridge_private"

#include <dmsdk/sdk.h>

#ifdef DM_PLATFORM_HTML5

#include <string.h>
#include <js_listeners.h>

extern "C"
{
    void VkBridgeLibrary_Init();
    void VkBridgeLibrary_Send(const int cb_id, const char *name, const char *cdata);
    void VkBridgeLibrary_SetWebViewBannerConfigs(const char *position, const int count);
    void VkBridgeLibrary_LoadWebViewBanner(const int cb_id);
    void VkBridgeLibrary_RefreshWebViewBanner(const int cb_id);
    const bool VkBridgeLibrary_UnloadWebViewBanner();
    const bool VkBridgeLibrary_ShowWebViewBanner();
    const bool VkBridgeLibrary_HideWebViewBanner();
    const bool VkBridgeLibrary_Supports(const char *name);
    const bool VkBridgeLibrary_isWebView();
    const bool VkBridgeLibrary_isStandalone();
    const bool VkBridgeLibrary_isEmbedded();
    const bool VkBridgeLibrary_isIframe();
}

static int AddListener(lua_State *L)
{
    AddEventListener(L);
    return 0;
}

static int RemoveListener(lua_State *L)
{
    RemoveEventListener(L);
    return 0;
}

static int InitCallbacks(lua_State *L)
{
    VkBridgeLibrary_Init();
    RegisterCallbacks();
    return 0;
}

static int Bridge_Send(lua_State *L)
{
    if (lua_isstring(L, 3))
    {
        VkBridgeLibrary_Send(luaL_checkint(L, 1), luaL_checkstring(L, 2), luaL_checkstring(L, 3));
    }
    else
    {
        VkBridgeLibrary_Send(luaL_checkint(L, 1), luaL_checkstring(L, 2), 0);
    }
    return 0;
}

static int SetWVBannerConfigs(lua_State *L)
{
    VkBridgeLibrary_SetWebViewBannerConfigs(luaL_checkstring(L, 1), luaL_checkint(L, 2));
    return 0;
}

static int LoadWVBanner(lua_State *L)
{
    VkBridgeLibrary_LoadWebViewBanner(luaL_checkint(L, 1));
    return 0;
}

static int RefreshWVBanner(lua_State *L)
{
    VkBridgeLibrary_RefreshWebViewBanner(luaL_checkint(L, 1));
    return 0;
}

static int UnloadWVBanner(lua_State *L)
{
    lua_pushboolean(L, VkBridgeLibrary_UnloadWebViewBanner());
    return 1;
}

static int ShowWVBanner(lua_State *L)
{
    lua_pushboolean(L, VkBridgeLibrary_ShowWebViewBanner());
    return 1;
}

static int HideWVBanner(lua_State *L)
{
    lua_pushboolean(L, VkBridgeLibrary_HideWebViewBanner());
    return 1;
}

static int Supports(lua_State *L)
{
    bool result = VkBridgeLibrary_Supports(luaL_checkstring(L, 1));
    lua_pushboolean(L, result);
    return 1;
}

static int IsWebView(lua_State *L)
{
    lua_pushboolean(L, VkBridgeLibrary_isWebView());
    return 1;
}

static int IsStandalone(lua_State *L)
{
    lua_pushboolean(L, VkBridgeLibrary_isStandalone());
    return 1;
}

static int IsIframe(lua_State *L)
{
    lua_pushboolean(L, VkBridgeLibrary_isIframe());
    return 1;
}

static int IsEmbedded(lua_State *L)
{
    lua_pushboolean(L, VkBridgeLibrary_isEmbedded());
    return 1;
}

// Functions exposed to Lua
static const luaL_reg Module_methods[] =
    {
        {"add_listener", AddListener},
        {"remove_listener", RemoveListener},
        {"init_callbacks", InitCallbacks},
        {"send", Bridge_Send},
        {"supports", Supports},
        {"is_webview", IsWebView},
        {"is_standalone", IsStandalone},
        {"is_iframe", IsIframe},
        {"is_embedded", IsEmbedded},
        {"set_wv_banner_configs", SetWVBannerConfigs},
        {"load_wv_banner", LoadWVBanner},
        {"unload_wv_banner", UnloadWVBanner},
        {"refresh_wv_banner", RefreshWVBanner},
        {"show_wv_banner", ShowWVBanner},
        {"hide_wv_banner", HideWVBanner},
        {0, 0}};

static void LuaInit(lua_State *L)
{
    int top = lua_gettop(L);

    // Register lua names
    luaL_register(L, MODULE_PRIVATE_NAME, Module_methods);

    lua_pop(L, 1);
    assert(top == lua_gettop(L));
}

dmExtension::Result InitializeVkBridge(dmExtension::Params *params)
{
    // Init Lua
    LuaInit(params->m_L);
    dmLogInfo("Registered %s Extension\n", MODULE_NAME);
    return dmExtension::RESULT_OK;
}

dmExtension::Result FinalizeVkBridge(dmExtension::Params *params)
{
    return dmExtension::RESULT_OK;
}

#else // unsupported platforms

static dmExtension::Result InitializeVkBridge(dmExtension::Params *params)
{
    dmLogInfo("Extension %s does not work for this platform\n", MODULE_NAME);
    return dmExtension::RESULT_OK;
}

static dmExtension::Result FinalizeVkBridge(dmExtension::Params *params)
{
    return dmExtension::RESULT_OK;
}

#endif

DM_DECLARE_EXTENSION(VkBridge, LIB_NAME, 0, 0, InitializeVkBridge, 0, 0, FinalizeVkBridge)
