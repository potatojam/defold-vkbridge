#pragma once

#include <dmsdk/sdk.h>
#include <string.h>

typedef void (*ObjectMessage)(const int cb_id, const char *message_id, const char *message);
typedef void (*NoMessage)(const int cb_id, const char *message_id);
typedef void (*NumberMessage)(const int cb_id, const char *message_id, float message);
typedef void (*BooleanMessage)(const int cb_id, const char *message_id, int message);

extern "C"
{
    void VkBridgeLibrary_RegisterCallbacks(ObjectMessage cb_obj,
                                           ObjectMessage cb_string,
                                           NoMessage cb_empty,
                                           NumberMessage cb_num,
                                           BooleanMessage cb_bool);
    void VkBridgeLibrary_RemoveCallbacks();
}

struct PrivateListener
{
    PrivateListener() : m_L(0), m_Callback(LUA_NOREF), m_Self(LUA_NOREF) {}
    lua_State *m_L;
    int m_Callback;
    int m_Self;
    int m_OnlyId;
};

void UnregisterCallback(lua_State *L, PrivateListener *cbk);
int GetEqualIndexOfListener(lua_State *L, PrivateListener *cbk);
bool CheckCallbackAndInstance(PrivateListener *cbk);
void SendObjectMessage(const int cb_id, const char *message_id, const char *message);
void SendStringMessage(const int cb_id, const char *message_id, const char *message);
void SendEmptyMessage(const int cb_id, const char *message_id);
void SendNumMessage(const int cb_id, const char *message_id, float message);
void SendBoolMessage(const int cb_id, const char *message_id, int message);
void AddEventListener(lua_State *L);
void RemoveEventListener(lua_State *L);
void RegisterCallbacks();

static dmArray<PrivateListener> m_Listeners;