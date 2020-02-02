const fe = @import("fire_engine.zig");
const palette = @import("fire_palette.zig");
const std = @import("std");

const doom_alpha_palette = [_]u8{
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
};

pub fn init() fe.FireRenderer {
    return fe.FireRenderer{ .render_function = renderFire, .poll_function = pollForExit, .cleanup_function = cleanup };
}

pub fn renderFire(buffer: fe.FireBuffer) void {
    var y: usize = 0;
    while (y < buffer.height) : (y += 1) {
        var x: usize = 0;

        while (x < buffer.width) : (x += 1) {
            const pos = (y * buffer.width) + x;
            var pixel = buffer.buffer[pos] % doom_alpha_palette.len;

            var char: u8 = doom_alpha_palette[pixel];
            std.debug.warn("{c}", .{char});
        }
        std.debug.warn("\n", .{});
    }
    std.debug.warn("\n", .{});
}

pub fn pollForExit() bool {
    return false;
}

pub fn cleanup() void {}
