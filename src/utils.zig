const window = @import("window");
const cString = @cImport({
    @cInclude("string.h");
});
const json = std.json;
const std = @import("std");
pub fn strdup(str: [:0]const u8) ![*:0]u8 {
    return cString.strdup(str) orelse error.OutOfMemory;
}

pub fn loadConfig(filepath: []const u8, a: std.mem.Allocator) !window.Config {
    const parsed = try json.parseFromSlice(window.Config, a, filepath, .{});
    defer parsed.deinit();
    return parsed.value;
}
