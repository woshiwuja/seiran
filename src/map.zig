const rl = @import("raylib");

pub fn loadMap(image: [*:0]const u8) !struct { texture: rl.Texture2D, model: rl.Model } {
    const heightMapImage = try rl.loadImage(image);
    const heightMapTexture = try rl.loadTextureFromImage(heightMapImage);
    const meshSize: rl.Vector3 = .{ .x = 200, .y = 45, .z = 190 };
    const mesh = rl.genMeshHeightmap(heightMapImage, meshSize);
    const model = try rl.loadModelFromMesh(mesh);
    rl.unloadImage(heightMapImage);
    return .{ .texture = heightMapTexture, .model = model };
}

pub fn handleNewMap(map: rl.Model) !rl.Model {
    if (rl.isFileDropped()) {
        const filepath: rl.FilePathList = rl.loadDroppedFiles();
        rl.unloadModel(map);
        const mapModel = try loadMap(filepath.paths[0]);
        rl.unloadDroppedFiles(filepath);
        return mapModel.model;
    }
    return map;
}

pub fn drawMap(map: rl.Model, position: rl.Vector3, scale: f32, tint: rl.Color, water: bool) void {
    if (water) {
        const waterLevel = rl.Vector3{ .x = -8, .y = 10, .z = -8 };
        const waterSize: rl.Vector2 = .{ .x = 3000, .y = 3000 };
        rl.drawPlane(waterLevel, waterSize, rl.Color.blue);
    }
    rl.drawModel(map, position, scale, tint);
    rl.drawGrid(2000, 1);
    return;
}
