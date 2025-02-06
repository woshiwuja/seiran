const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const ziglua = @import("ziglua");
//const clay = @cImport({
//    @cInclude("src/clay.h");
//});
const print = std.debug.print;

const cString = @cImport({
    @cInclude("string.h");
});

fn strdup(str: [:0]const u8) ![*:0]u8 {
    return cString.strdup(str) orelse error.OutOfMemory;
}

fn loadMap(image: [*:0]const u8) !rl.Model {
    const heightMapImage = try rl.loadImage(image);
    const heightMapTexture = try rl.loadTextureFromImage(heightMapImage);
    defer rl.unloadTexture(heightMapTexture);
    const meshSize: rl.Vector3 = .{ .x = 200, .y = 45, .z = 190 };
    const mesh = rl.genMeshHeightmap(heightMapImage, meshSize);
    _ = rl.exportMesh(mesh, "map");
    var map = try rl.loadModelFromMesh(mesh);
    map.materials[0].maps[0].texture = heightMapTexture;
    rl.unloadImage(heightMapImage);
    return map;
}

fn initLua() !void {}

//should come from settings file
fn initWindowSettings() void {
    rl.toggleFullscreen();
    rl.setTargetFPS(60);
    rl.disableCursor();
    rl.setExitKey(rl.KeyboardKey.home); //home key raylib.zig:1694
}

fn initDefaultCamera() rl.Camera3D {
    const cameraPosition: rl.Vector3 = .{ .x = -8, .y = 10, .z = -8 };
    const cameraUp: rl.Vector3 = .{ .x = 0, .y = 1, .z = 0 };
    const cameraTarget: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 };
    const cameraProjection = rl.CameraProjection.perspective;
    const camera = rl.Camera{ .fovy = 45.0, .position = cameraPosition, .up = cameraUp, .projection = cameraProjection, .target = cameraTarget };
    return camera;
}

fn drawMap(map: rl.Model, position: rl.Vector3, scale: f32, tint: rl.Color, water: bool) void {
    if (water) {
        const waterLevel = rl.Vector3{ .x = -8, .y = 10, .z = -8 };
        const waterSize: rl.Vector2 = .{ .x = 3000, .y = 3000 };
        rl.drawPlane(waterLevel, waterSize, rl.Color.blue);
    }
    rl.drawModel(map, position, scale, tint);
    rl.drawGrid(2000, 1);
    return;
}

const screenWidth: i32 = 1920;
const screenHeight: i32 = 1080;
pub fn main() !void {
    rl.initWindow(screenWidth, screenHeight, "Steel Shell");
    defer rl.closeWindow();
    initWindowSettings();
    var camera = initDefaultCamera();
    const map = try loadMap("assets/monzuno.png");
    const mapPosition = rl.Vector3{ .x = 0, .y = 4, .z = 0 };
    const text = "hello";
    const textCopy = try strdup(text);
    defer std.c.free(textCopy);
    var cursorEnabled = false;
    rl.updateCamera(&camera, rl.CameraMode.free);
    while (!rl.windowShouldClose()) {
        rl.updateCamera(&camera, rl.CameraMode.free);
        if (rl.isKeyPressed(rl.KeyboardKey.escape)) {
            if (!cursorEnabled) {
                rl.enableCursor();
                rl.updateCamera(&camera, rl.CameraMode.orbital);
                cursorEnabled = !cursorEnabled;
            } else {
                rl.disableCursor();
                cursorEnabled = !cursorEnabled;
                rl.updateCamera(&camera, rl.CameraMode.free);
            }
        }
        rl.beginDrawing();
        //DRAWING
        rl.clearBackground(rl.Color.white);
        rl.beginMode3D(camera);
        drawMap(map, mapPosition, 1, rl.Color.brown, true);
        rl.endMode3D();
        rl.drawFPS(100, 100);
        _ = rg.guiMessageBox(rl.Rectangle{ .height = 400, .width = 800, .x = -40, .y = -40 }, "hello", "hello", "bottone");
        //END DRAWING
        rl.endDrawing();
    }
    rl.unloadModel(map);
}
