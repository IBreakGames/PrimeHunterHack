#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "Windows.h"

struct windowProperties {
   char exeName[512];
   char windowName[32];
   BOOL isCorrectWindow;
   int left;
   int right;
   int top;
   int bottom;
   int height;
   int width;
};

struct windowProperties getWindowProperties() {
   struct windowProperties props;
   props.isCorrectWindow = FALSE;
   props.left = 0;
   props.right = 0;
   props.top = 0;
   props.bottom = 0;
   props.height = 0;
   props.width = 0;
   
   RECT windowPosition;
   HWND currentWindow = GetForegroundWindow();
   GetWindowModuleFileName(currentWindow, props.exeName, sizeof(props.exeName));
   GetWindowText(currentWindow, props.windowName, sizeof(props.windowName));
   char *correctEXE = strstr(props.exeName, "DeSmuME");
   char *correctWindow = strstr(props.windowName, "DeSmuME");
   if (GetWindowRect(currentWindow, &windowPosition) && correctEXE != NULL && correctWindow != NULL) {
      props.isCorrectWindow = TRUE;
      props.left = windowPosition.left;
      props.right = windowPosition.right;
      props.top = windowPosition.top;
      props.bottom = windowPosition.bottom;
      props.height = props.bottom - props.top;
      props.width = props.right - props.left;
   }
   return props;
}

void addEntryString(lua_State *L, char *key, char *value) {
   lua_pushstring(L, key);
   lua_pushstring(L, value);
   lua_settable(L, -3);
};

void addEntryInt(lua_State *L, char *key, int value) {
   lua_pushstring(L, key);
   lua_pushinteger(L, value);
   lua_settable(L, -3);
};

void addEntryBool(lua_State *L, char *key, BOOL value) {
   lua_pushstring(L, key);
   lua_pushboolean(L, value);
   lua_settable(L, -3);
};

static int l_windowProps(lua_State *L) {
   struct windowProperties props = getWindowProperties();
   lua_newtable(L);
   addEntryString(L, "windowName", props.windowName);
   addEntryString(L, "exeName", props.exeName);
   addEntryBool(L, "isCorrectWindow", props.isCorrectWindow);
   addEntryInt(L, "left", props.left);
   addEntryInt(L, "right", props.right);
   addEntryInt(L, "top", props.top);
   addEntryInt(L, "bottom", props.bottom);
   addEntryInt(L, "width", props.width);
   addEntryInt(L, "height", props.height);
   return 1;
}

static const struct luaL_reg windowLib[] = {
   {"getProperties", l_windowProps},
   {NULL, NULL}
};

int luaopen_windowProperties(lua_State *L) {
   luaL_register(L, "windowProperties", windowLib);
   return 1;
}
