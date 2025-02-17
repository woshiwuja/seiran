const rl = @import("raylib");
pub fn handleCursor() void {
    if (rl.isKeyPressed(rl.KeyboardKey.escape)) {
        if (rl.isCursorHidden()) {
            rl.enableCursor();
        } else {
            rl.disableCursor();
        }
    }
}
