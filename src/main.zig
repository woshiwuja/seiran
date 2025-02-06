const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
//const clay = @cImport({
//    @cInclude("src/clay.h");
//});
const print = std.debug.print;

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

pub fn main() !void {
    const screenWidth: i32 = 1920;
    const screenHeight: i32 = 1080;
    rl.initWindow(screenWidth, screenHeight, "Steel Shell");
    initWindowSettings();
    var camera = initDefaultCamera();
    const heightMapImage = try rl.loadImage("assets/monzuno.png");
    const heightMapTexture = try rl.loadTextureFromImage(heightMapImage);
    defer rl.unloadTexture(heightMapTexture);
    const meshSize: rl.Vector3 = .{ .x = 384, .y = 45, .z = 190 };
    const mesh = rl.genMeshHeightmap(heightMapImage, meshSize);
    _ = rl.exportMesh(mesh, "map");
    var map = try rl.loadModelFromMesh(mesh);
    map.materials[0].maps[0].texture = heightMapTexture;
    const mapPosition = rl.Vector3{ .x = -8, .y = 4, .z = -8 };
    const water = rl.Vector3{ .x = -8, .y = 10, .z = -8 };
    const waterSize: rl.Vector2 = .{ .x = 3000, .y = 3000 };
    rl.unloadImage(heightMapImage);
    defer rl.closeWindow();
    while (!rl.windowShouldClose()) {
        rl.updateCamera(&camera, rl.CameraMode.free);
        rl.beginDrawing();
        rl.clearBackground(rl.Color.ray_white);
        rl.beginMode3D(camera);
        rl.drawModel(map, mapPosition, 1, rl.Color.brown);
        rl.drawGrid(2000, 1);
        rl.drawPlane(water, waterSize, rl.Color.sky_blue);
        rl.endMode3D();
        const windowBoxRect = rl.Rectangle{ .height = 200, .width = 300, .x = 40, .y = 40 };
        _ = rg.guiWindowBox(windowBoxRect, "finestra");
        rl.drawFPS(100, 100);
        //rl.drawTexture(heightMapTexture, screenWidth - heightMapTexture.width - 20, 20, rl.Color.white);
        //rl.drawRectangleLines(screenWidth - heightMapTexture.width - 20, 20, heightMapTexture.width, heightMapTexture.height, rl.Color.green);
        rl.endDrawing();
    }
    rl.unloadModel(map);
}
