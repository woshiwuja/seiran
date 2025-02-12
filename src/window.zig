const rl = @import("raylib");

pub const windowMode = enum { fullscreen, windowed, borderless };

pub const Config: "windowed" = struct {
    screenHeight: i32,
    screenWidth: i32,
    windowMode: windowMode,
};

pub fn initDefaultCamera() rl.Camera3D {
    const cameraPosition: rl.Vector3 = .{ .x = -8, .y = 10, .z = -8 };
    const cameraUp: rl.Vector3 = .{ .x = 0, .y = 1, .z = 0 };
    const cameraTarget: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 };
    const cameraProjection = rl.CameraProjection.perspective;
    const camera = rl.Camera{ .fovy = 45.0, .position = cameraPosition, .up = cameraUp, .projection = cameraProjection, .target = cameraTarget };
    return camera;
}

pub fn initWindowSettings(mode: windowMode) void {
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
