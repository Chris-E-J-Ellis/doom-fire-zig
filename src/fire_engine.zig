const std = @import("std");

var prng = std.rand.DefaultPrng.init(0);

pub const FireBuffer = struct {
    width: usize,
    height: usize,
    buffer: []u8,
};

pub const FireRenderer = struct {
    render_function: *const fn (buffer: FireBuffer) void,
    poll_function: *const fn () bool,
    cleanup_function: *const fn () void,

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
    const pixel = buffer.buffer[source_position];
    if (pixel == 0) {
        buffer.buffer[source_position - buffer.width] = 0;
    } else {
        // Decay range should be 0..3, but I prefer the way 0..2 looks.
        const decay = prng.random().intRangeAtMost(u8, 0, 2);

        // decay subtraction may overflow, do it in the next step.
        const destination_position = (source_position - buffer.width + 1);
        const dest_sub_decay_result = @subWithOverflow(destination_position, decay);
        if (dest_sub_decay_result[1] != 0) {
            return;
        }

        buffer.buffer[dest_sub_decay_result[0]] = pixel - (decay & 1);
    }
}
