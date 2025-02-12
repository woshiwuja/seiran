const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const ziglua = @import("ziglua");
const window = @import("window.zig");
const utils = @import("utils.zig");
const lfunc = @import("lua_functions.zig");
const print = std.debug.print;
const Lua = ziglua.Lua;

fn loadMap(image: [*:0]const u8) !struct { texture: rl.Texture2D, model: rl.Model } {
    const heightMapImage = try rl.loadImage(image);
    const heightMapTexture = try rl.loadTextureFromImage(heightMapImage);
    const meshSize: rl.Vector3 = .{ .x = 200, .y = 45, .z = 190 };
    const mesh = rl.genMeshHeightmap(heightMapImage, meshSize);
    _ = rl.exportMesh(mesh, "map");
    const model = try rl.loadModelFromMesh(mesh);
    rl.unloadImage(heightMapImage);
    return .{ .texture = heightMapTexture, .model = model };
}

fn handleCursor() void {
    if (rl.isKeyPressed(rl.KeyboardKey.escape)) {
        if (rl.isCursorHidden()) {
            rl.enableCursor();
        } else {
            rl.disableCursor();
        }
    }
}

fn handleNewMap(map: rl.Model) !rl.Model {
    if (rl.isFileDropped()) {
        const filepath: rl.FilePathList = rl.loadDroppedFiles();
        rl.unloadModel(map);
        const textBox = rl.Rectangle{ .height = 100, .width = 100, .x = 800, .y = 900 };
        const text = try utils.strdup("loading");
        rl.beginDrawing();
        _ = rg.guiTextBox(textBox, text, 12, false);
        rl.endDrawing();
        const mapModel = try loadMap(filepath.paths[0]);
        rl.unloadDroppedFiles(filepath);
        return mapModel.model;
    }
    return map;
}

//should come from settings file

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
    window.initWindowSettings(window.windowMode.fullscreen);
    var camera = window.initDefaultCamera();

    var map = try loadMap("assets/monzuno.png");
    const mapPosition = rl.Vector3{ .x = -8.0, .y = 0.0, .z = -8.0 };

    map.model.materials[0].maps[@intFromEnum(rl.MATERIAL_MAP_DIFFUSE)].texture = map.texture;
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
        handleCursor();
        rl.beginDrawing();
        //DRAWING
        rl.clearBackground(rl.Color.white);
        rl.beginMode3D(camera);
        map.model = try handleNewMap(map.model);
        rl.drawModel(samuraiModel, mapPosition, 1, rl.Color.lime);
        drawMap(map.model, mapPosition, 20, rl.Color.brown, false);
        rl.endMode3D();
        rl.drawFPS(100, 100);
        //END DRAWING
        rl.endDrawing();
    }
    rl.unloadModel(map.model);
    rl.unloadModel(samuraiModel);
    rl.unloadTexture(map.texture);
}
