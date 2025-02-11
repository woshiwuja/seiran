const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const ziglua = @import("ziglua");
const json = std.json;
//const clay = @cImport({
//    @cInclude("src/clay.h");
//});
const print = std.debug.print;

const cString = @cImport({
    @cInclude("string.h");
});

const windowMode = enum { fullscreen, windowed, borderless };

const Config: "windowed" = struct {
    screenHeight: i32,
    screenWidth: i32,
    windowMode: windowMode,
};

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
    const map = try rl.loadModelFromMesh(mesh);
    rl.unloadImage(heightMapImage);
    return map;
}

fn loadConfig(filepath: []const u8, a: std.mem.Allocator) !Config {
    const parsed = try json.parseFromSlice(Config, a, filepath, .{});
    defer parsed.deinit();
    return parsed.value;
}

fn initLua() !void {}
fn handleCursor(isCursorEnabled: bool) !bool {
    if (rl.isKeyPressed(rl.KeyboardKey.escape)) {
        if (!isCursorEnabled) {
            const textBox = rl.Rectangle{ .height = 100, .width = 100, .x = 800, .y = 900 };
            const text = try strdup("loading");
            _ = rg.guiTextBox(textBox, text, 12, false);
            rl.enableCursor();
            const cc: bool = !isCursorEnabled;
            return cc;
        } else {
            rl.disableCursor();
            const cc: bool = !isCursorEnabled;
            return cc;
        }
    }
    return isCursorEnabled;
}

fn handleNewMap(map: rl.Model) !rl.Model {
    if (rl.isFileDropped()) {
        const filepath: rl.FilePathList = rl.loadDroppedFiles();
        rl.unloadModel(map);
        const textBox = rl.Rectangle{ .height = 100, .width = 100, .x = 800, .y = 900 };
        const text = try strdup("loading");
        _ = rg.guiTextBox(textBox, text, 12, false);
        const mapModel = try loadMap(filepath.paths[0]);
        rl.unloadDroppedFiles(filepath);
        return mapModel;
    }
    return map;
}

//should come from settings file
fn initWindowSettings(mode: windowMode) void {
    if (mode == windowMode.fullscreen) {
        rl.toggleFullscreen();
    } else if (mode == windowMode.windowed) {
        rl.maximizeWindow();
    } else if (mode == windowMode.borderless) {
        rl.toggleBorderlessWindowed();
    }
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
    initWindowSettings(windowMode.fullscreen);
    var camera = initDefaultCamera();
    var map = try loadMap("assets/monzuno.png");
    const mapPosition = rl.Vector3{ .x = -8.0, .y = 4.0, .z = -8.0 };
    const text = "hello";
    const textCopy = try strdup(text);
    defer std.c.free(textCopy);
    var isCursorEnabled = false;
    rl.updateCamera(&camera, rl.CameraMode.free);
    while (!rl.windowShouldClose()) {
        rl.updateCamera(&camera, rl.CameraMode.free);
        isCursorEnabled = try handleCursor(isCursorEnabled);
        rl.beginDrawing();
        //DRAWING
        rl.clearBackground(rl.Color.white);
        rl.beginMode3D(camera);
        map = try handleNewMap(map);
        drawMap(map, mapPosition, 1.0, rl.Color.brown, true);
        rl.endMode3D();
        rl.drawFPS(100, 100);
        //END DRAWING
        rl.endDrawing();
    }
    rl.unloadModel(map);
}
