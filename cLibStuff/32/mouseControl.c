
#include <stdio.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "Windows.h"
#include "WinUser.h"

void addEntryInt(lua_State *L, char *key, int value) {
   lua_pushstring(L, key);
   lua_pushinteger(L, value);
   lua_settable(L, -3);
};

static int l_getMouse(lua_State *L) {
   POINT cursor;
   GetCursorPos(&cursor);
   lua_newtable(L);
   addEntryInt(L, "x", cursor.x);
   addEntryInt(L, "y", cursor.y);
   return 1;
}

static int l_moveMouse(lua_State *L) {
   double mouseX = luaL_checknumber(L, 1);
   double mouseY = luaL_checknumber(L, 2);
   SetCursorPos(mouseX, mouseY);
   return 1;
}

static const struct luaL_reg mouseLib[] = {
   {"moveMouse", l_moveMouse},
   {"getMouse", l_getMouse},
   {NULL, NULL}
};

int luaopen_mouseControl(lua_State *L) {
   luaL_register(L, "mouseControl", mouseLib);
   return 1;
}
