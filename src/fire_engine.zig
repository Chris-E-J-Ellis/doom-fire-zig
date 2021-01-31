const std = @import("std");

var prng = std.rand.DefaultPrng.init(0);

pub const FireBuffer = struct {
    width: usize,
    height: usize,
    buffer: []u8,
};

pub const FireRenderer = struct {
    render_function: fn (buffer: FireBuffer) void,
    poll_function: fn () bool,
    cleanup_function: fn () void,

    pub fn render(self: FireRenderer, buffer: FireBuffer) void {
        self.render_function(buffer);
    }

    pub fn pollForExit(self: FireRenderer) bool {
        return self.poll_function();
    }

    pub fn cleanup(self: FireRenderer) void {
        self.cleanup_function();
    }
};

pub fn initialiseBuffer(buffer: FireBuffer, ignition_value: u8) void {
    const final_row_index = buffer.width * (buffer.height - 1);
    for (buffer.buffer[0..final_row_index]) |*x| {
        x.* = 0;
    }

    for (buffer.buffer[final_row_index..buffer.buffer.len]) |*x| {
        x.* = ignition_value;
    }

    prng = std.rand.DefaultPrng.init(std.crypto.random.int(u64));
}

pub fn stepFire(buffer: FireBuffer) void {
    var x: usize = 0;
    while (x < buffer.width) : (x += 1) {
        var y: usize = 1;
        while (y < buffer.height) : (y += 1) {
            const pos = (y * buffer.width) + x;
            spreadFire(buffer, pos);
        }
    }
}

fn spreadFire(buffer: FireBuffer, source_position: usize) void {
    var pixel = buffer.buffer[source_position];
    if (pixel == 0) {
        buffer.buffer[source_position - buffer.width] = 0;
    } else {
        // Decay range should be 0..3, but I prefer the way 0..2 looks.
        var decay = prng.random.intRangeAtMost(u8, 0, 2);
        var destination_position = (source_position - buffer.width + 1);
        if (@subWithOverflow(usize, destination_position, decay, &destination_position)) {
            return;
        }
        buffer.buffer[destination_position] = pixel - (decay & 1);
    }
}
