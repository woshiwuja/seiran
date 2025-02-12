// implementing functions that can be called from lua.
const ziglua = @import("ziglua");
const Lua = ziglua.Lua;
const raylib = @import("raylib");
const print = std.debug.print;
const std = @import("std");

pub fn onUpdate(L: *Lua) void {
    print("{}", .{L.status()});
}

pub fn onStart(L: *Lua) void {
    print("{}", .{L.status()});
}

pub fn onTrigger(L: *Lua) void {
    print("{}", .{L.status()});
}

pub fn registerFunctions(L: *Lua) void {
    //L.pushFunction(ziglua.wrap(onUpdate()));
    //L.setGlobal("OnStart");
    //L.pushFunction(ziglua.wrap(onStart()));
    //L.setGlobal("OnUpdate");
    //L.pushFunction(ziglua.wrap(onUpdate()));
    //L.setGlobal("OnTrigger");
    print("{}", .{L.status()});
}

pub fn initLuaFunctions(L: *Lua) !void {
    registerFunctions(L);
    L.openBase();
}
