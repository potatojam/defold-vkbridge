#include <dmsdk/sdk.h>
#include <string.h>
#include <js_listeners.h>

// #ifndef DM_PLATFORM_HTML5

bool CheckCallbackAndInstance(PrivateListener *cbk)
{
    if (cbk->m_Callback == LUA_NOREF)
    {
        dmLogInfo("VkBridgePrivate callback do not exist.");
        return false;
    }
    lua_State *L = cbk->m_L;
    int top = lua_gettop(L);
    lua_rawgeti(L, LUA_REGISTRYINDEX, cbk->m_Callback);
    //[-1] - callback
    lua_rawgeti(L, LUA_REGISTRYINDEX, cbk->m_Self);
    //[-1] - self
    //[-2] - callback
    lua_pushvalue(L, -1);
    //[-1] - self
    //[-2] - self
    //[-3] - callback
    dmScript::SetInstance(L);
    //[-1] - self
    //[-2] - callback
    if (!dmScript::IsInstanceValid(L))
    {
        UnregisterCallback(L, cbk);
        dmLogError("Could not run VkBridgePrivate callback because the instance has been deleted.");
        lua_pop(L, 2);
        assert(top == lua_gettop(L));
        return false;
    }
    return true;
}

void SendObjectMessage(const int cb_id, const char *message_id, const char *message)
{
    for (int i = m_Listeners.Size() - 1; i >= 0; --i)
    {
        PrivateListener *cbk = &m_Listeners[i];
        lua_State *L = cbk->m_L;
        int top = lua_gettop(L);
        bool is_fail = false;
        {
            lua_pushinteger(L, cb_id);
            if (message_id)
            {
                lua_pushstring(L, message_id);
            }
            else
            {
                lua_pushnil(L);
            }

            dmJson::Document doc;
            dmJson::Result r = dmJson::Parse(message, &doc);
            if (r == dmJson::RESULT_OK && doc.m_NodeCount > 0)
            {
                char error_str_out[128];
                if (dmScript::JsonToLua(L, &doc, 0, error_str_out, sizeof(error_str_out)) < 0)
                {
                    dmLogError("Failed converting object JSON to Lua; %s", error_str_out);
                    is_fail = true;
                }
            }
            else
            {
                dmLogError("Failed to parse JS object(%d): (%s)", r, message);
                is_fail = true;
            }
            dmJson::Free(&doc);
            if (is_fail)
            {
                lua_pop(L, 3);
                assert(top == lua_gettop(L));
                return;
            }
            int ret = lua_pcall(L, 4, 0, 0);
            if (ret != 0)
            {
                dmLogError("Error running callback: %s", lua_tostring(L, -1));
                lua_pop(L, 1);
            }
        }
        assert(top == lua_gettop(L));
    }
}

void SendStringMessage(const int cb_id, const char *message_id, const char *message)
{
    for (int i = m_Listeners.Size() - 1; i >= 0; --i)
    {
        if (i > m_Listeners.Size())
        {
            return;
        }
        PrivateListener *cbk = &m_Listeners[i];
        lua_State *L = cbk->m_L;
        int top = lua_gettop(L);
        if (cbk->m_OnlyId == cb_id && CheckCallbackAndInstance(cbk))
        {
            lua_pushinteger(L, cb_id);
            if (message_id)
            {
                lua_pushstring(L, message_id);
            }
            else
            {
                lua_pushnil(L);
            }
            lua_pushstring(L, message);

            int ret = lua_pcall(L, 4, 0, 0);
            if (ret != 0)
            {
                dmLogError("Error running callback: %s", lua_tostring(L, -1));
                lua_pop(L, 1);
            }
        }
        assert(top == lua_gettop(L));
    }
}

void SendEmptyMessage(const int cb_id, const char *message_id)
{
    for (int i = m_Listeners.Size() - 1; i >= 0; --i)
    {
        if (i > m_Listeners.Size())
        {
            return;
        }
        PrivateListener *cbk = &m_Listeners[i];
        lua_State *L = cbk->m_L;
        int top = lua_gettop(L);
        if (cbk->m_OnlyId == cb_id && CheckCallbackAndInstance(cbk))
        {
            lua_pushinteger(L, cb_id);
            if (message_id)
            {
                lua_pushstring(L, message_id);
            }
            else
            {
                lua_pushnil(L);
            }

            int ret = lua_pcall(L, 3, 0, 0);
            if (ret != 0)
            {
                dmLogError("Error running callback: %s", lua_tostring(L, -1));
                lua_pop(L, 1);
            }
        }
        assert(top == lua_gettop(L));
    }
}

void SendNumMessage(const int cb_id, const char *message_id, float message)
{
    for (int i = m_Listeners.Size() - 1; i >= 0; --i)
    {
        if (i > m_Listeners.Size())
        {
            return;
        }
        PrivateListener *cbk = &m_Listeners[i];
        lua_State *L = cbk->m_L;
        int top = lua_gettop(L);
        if (cbk->m_OnlyId == cb_id && CheckCallbackAndInstance(cbk))
        {
            lua_pushinteger(L, cb_id);
            if (message_id)
            {
                lua_pushstring(L, message_id);
            }
            else
            {
                lua_pushnil(L);
            }
            lua_pushnumber(L, message);

            int ret = lua_pcall(L, 4, 0, 0);
            if (ret != 0)
            {
                dmLogError("Error running callback: %s", lua_tostring(L, -1));
                lua_pop(L, 1);
            }
        }
        assert(top == lua_gettop(L));
    }
}

void SendBoolMessage(const int cb_id, const char *message_id, int message)
{
    for (int i = m_Listeners.Size() - 1; i >= 0; --i)
    {
        PrivateListener *cbk = &m_Listeners[i];
        lua_State *L = cbk->m_L;
        int top = lua_gettop(L);
        if (cbk->m_OnlyId == cb_id && CheckCallbackAndInstance(cbk))
        {
            lua_pushinteger(L, cb_id);
            if (message_id)
            {
                lua_pushstring(L, message_id);
            }
            else
            {
                lua_pushnil(L);
            }
            lua_pushboolean(L, message);

            int ret = lua_pcall(L, 4, 0, 0);
            if (ret != 0)
            {
                dmLogError("Error running callback: %s", lua_tostring(L, -1));
                lua_pop(L, 1);
            }
        }
        assert(top == lua_gettop(L));
    }
}

int GetEqualIndexOfListener(lua_State *L, PrivateListener *cbk)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, cbk->m_Callback);
    int first = lua_gettop(L);
    int second = first + 1;
    for (uint32_t i = 0; i != m_Listeners.Size(); ++i)
    {
        PrivateListener *cb = &m_Listeners[i];
        lua_rawgeti(L, LUA_REGISTRYINDEX, cb->m_Callback);
        if (lua_equal(L, first, second))
        {
            lua_pop(L, 1);
            lua_rawgeti(L, LUA_REGISTRYINDEX, cbk->m_Self);
            lua_rawgeti(L, LUA_REGISTRYINDEX, cb->m_Self);
            if (lua_equal(L, second, second + 1))
            {
                lua_pop(L, 3);
                return i;
            }
            lua_pop(L, 2);
        }
        else
        {
            lua_pop(L, 1);
        }
    }
    lua_pop(L, 1);
    return -1;
}

void UnregisterCallback(lua_State *L, PrivateListener *cbk)
{
    int index = GetEqualIndexOfListener(L, cbk);
    if (index >= 0)
    {
        if (cbk->m_Callback != LUA_NOREF)
        {
            dmScript::Unref(cbk->m_L, LUA_REGISTRYINDEX, cbk->m_Callback);
            dmScript::Unref(cbk->m_L, LUA_REGISTRYINDEX, cbk->m_Self);
            cbk->m_Callback = LUA_NOREF;
        }
        m_Listeners.EraseSwap(index);
        if (m_Listeners.Size() == 0)
        {
            VkBridgeLibrary_RemoveCallbacks();
        }
    }
    else
    {
        dmLogError("Can't remove a callback that didn't not register.");
    }
}

void AddEventListener(lua_State *L)
{
    PrivateListener cbk;
    cbk.m_L = dmScript::GetMainThread(L);
    cbk.m_OnlyId = luaL_checkint(L, 1);

    luaL_checktype(L, 2, LUA_TFUNCTION);
    lua_pushvalue(L, 2);
    cbk.m_Callback = dmScript::Ref(L, LUA_REGISTRYINDEX);

    dmScript::GetInstance(L);
    cbk.m_Self = dmScript::Ref(L, LUA_REGISTRYINDEX);

    if (cbk.m_Callback != LUA_NOREF)
    {
        int index = GetEqualIndexOfListener(L, &cbk);
        if (index < 0)
        {
            if (m_Listeners.Full())
            {
                m_Listeners.OffsetCapacity(1);
            }
            m_Listeners.Push(cbk);
        }
        else
        {
            dmLogError("Can't register a callback again. Callback has been registered before.");
        }
    }
}

void RemoveEventListener(lua_State *L)
{
    PrivateListener cbk;
    cbk.m_L = dmScript::GetMainThread(L);

    luaL_checktype(L, 1, LUA_TFUNCTION);
    lua_pushvalue(L, 1);

    cbk.m_Callback = dmScript::Ref(L, LUA_REGISTRYINDEX);

    dmScript::GetInstance(L);
    cbk.m_Self = dmScript::Ref(L, LUA_REGISTRYINDEX);

    UnregisterCallback(L, &cbk);
}

void RegisterCallbacks()
{
    VkBridgeLibrary_RegisterCallbacks(SendObjectMessage,
                                      SendStringMessage,
                                      SendEmptyMessage,
                                      SendNumMessage,
                                      SendBoolMessage);
}
