const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const ziglua = @import("ziglua");
const window = @import("window.zig");
const utils = @import("utils.zig");
const map = @import("map.zig");
const cm = @import("camera.zig");
const lfunc = @import("lua_functions.zig");
const print = std.debug.print;
const Lua = ziglua.Lua;

const screenWidth: i32 = 1920;
const screenHeight: i32 = 1080;
pub fn main() !void {
    rl.initWindow(screenWidth, screenHeight, "Seiran Engine - a lua scriptable engine made in zig");
    defer rl.closeWindow();
    window.initWindowSettings(window.windowMode.fullscreen);
    var camera = window.initDefaultCamera();

    var currentMap = try map.loadMap("assets/monzuno.png");
    const mapPosition = rl.Vector3{ .x = -8.0, .y = 0.0, .z = -8.0 };

    currentMap.model.materials[0].maps[@intFromEnum(rl.MATERIAL_MAP_DIFFUSE)].texture = currentMap.texture;
    const text = "hello";
    const textCopy = try utils.strdup(text);
    defer std.c.free(textCopy);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var lua = try Lua.init(allocator);
    defer lua.deinit();

    lfunc.registerFunctions(lua);

    const samuraiModel = try rl.loadModel("assets/cyber_samurai.glb");
    rl.updateCamera(&camera, rl.CameraMode.free);
    while (!rl.windowShouldClose()) {
        rl.updateCamera(&camera, rl.CameraMode.free);
        cm.handleCursor();
        rl.beginDrawing();
        //DRAWING
        rl.clearBackground(rl.Color.white);
        rl.beginMode3D(camera);
        currentMap.model = try map.handleNewMap(currentMap.model);
        rl.drawModel(samuraiModel, mapPosition, 1, rl.Color.white);
        map.drawMap(currentMap.model, mapPosition, 1, rl.Color.brown, false);
        rl.endMode3D();
        rl.drawFPS(100, 100);
        //END DRAWING
        rl.endDrawing();
    }
    rl.unloadModel(currentMap.model);
    rl.unloadModel(samuraiModel);
    rl.unloadTexture(currentMap.texture);
}
