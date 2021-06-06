const std = @import("std");
const fe = @import("fire_engine.zig");
const fr_text = @import("fire_renderer_text.zig");
const fr_sdl = @import("fire_renderer_sdl.zig");
const palette = @import("fire_palette.zig");
const process = std.process;

const ms_per_ns = 1_000_000;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    var arg_it = process.args();
    _ = arg_it.skip();

    const width = try parseArgOrPrintHelp(usize, arg_it.next(allocator), "Expected first argument to be WIDTH");
    const height = try parseArgOrPrintHelp(usize, arg_it.next(allocator), "Expected second argument to be HEIGHT");
    const delay_ms = parseArgOrPrintHelp(u64, arg_it.next(allocator), "Expected third argument to be SLEEP, using default 0ms") catch 0;
    const use_alternate_renderer = if (arg_it.next(allocator)) |_| true else false;
    const delay_ns = delay_ms * ms_per_ns;

    const buffer = try allocator.alloc(u8, width * height);
    const fireBuffer = fe.FireBuffer{
        .width = width,
        .height = height,
        .buffer = buffer[0..buffer.len],
    };

    const ignition_value = palette.getPaletteSize() - 1;
    fe.initialiseBuffer(fireBuffer, ignition_value);

    const renderer = if (use_alternate_renderer)
        fr_text.init()
    else
        try fr_sdl.init(fireBuffer, allocator);
    defer renderer.cleanup();

    var exit_requested = false;
    while (!exit_requested) {
        renderer.render_function(fireBuffer);
        fe.stepFire(fireBuffer);

        exit_requested = renderer.pollForExit();
        std.time.sleep(delay_ns);
    }
}

fn parseArgOrPrintHelp(comptime T: type, arg: ?std.process.ArgIterator.NextError![:0]u8, message: []const u8) !T {
    if (arg) |arg_unwrapped| {
        const radix = 10;
        const result = try std.fmt.parseInt(T, try arg_unwrapped, radix);
        return result;
    }

    std.debug.warn("{s}\n\n", .{message});
    printHelp();
    return error.InvalidArgs;
}

fn printHelp() void {
    std.debug.warn("Usage: doom-fire WIDTH HEIGHT [SLEEP] [RENDERER]\n", .{});
    std.debug.warn("       SLEEP    - Render loop delay in ms\n", .{});
    std.debug.warn("       RENDERER - Enable alternate renderer (current just outputs text) by supplying any value\n\n", .{});
}
