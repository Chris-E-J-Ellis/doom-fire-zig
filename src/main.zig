const std = @import("std");

pub fn main() void {
    const width = 10;
    const height = 10;
    const buffer = [_]u8{0} ** (width * height);

    var x: usize = 0;
    while (x < width) : (x += 1) {
        var y: usize = 0;
        while (y < height) : (y += 1) {
            //const pixel: u8 = if (buffer[4] == 0) '_' else '#';
            var pixel: u8 = '_';
            if (buffer[x] == 0) {
                pixel = '#';
            }
            std.debug.warn("{c}", pixel);
        }
        std.debug.warn("\n");
    }
}
