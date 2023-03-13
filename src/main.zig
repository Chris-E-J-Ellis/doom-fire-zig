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
    var allocator = arena.allocator();

    var arg_it = try process.argsWithAllocator(allocator);
    _ = arg_it.skip();

    const width = try parseArgOrPrintHelp(usize, arg_it.next(), "Expected first argument to be WIDTH");
    const height = try parseArgOrPrintHelp(usize, arg_it.next(), "Expected second argument to be HEIGHT");
    const delay_ms = parseArgOrPrintHelp(u64, arg_it.next(), "Expected third argument to be SLEEP, using default 0ms") catch 0;
    const use_alternate_renderer = if (arg_it.next()) |_| true else false;
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
        try fr_sdl.init(fireBuffer, &allocator);
    defer renderer.cleanup();

    var exit_requested = false;
    while (!exit_requested) {
        renderer.render_function(fireBuffer);
        fe.stepFire(fireBuffer);

        exit_requested = renderer.pollForExit();
        std.time.sleep(delay_ns);
    }
}

fn parseArgOrPrintHelp(comptime T: type, optional_arg: ?[:0]const u8, message: []const u8) !T {
    if (optional_arg) |arg| {
        const radix = 10;
        const result = try std.fmt.parseInt(T, arg, radix);
        return result;
    }

    std.log.warn("{s}\n\n", .{message});
    printHelp();
    return error.InvalidArgs;
}

fn printHelp() void {
    std.log.info("Usage: doom-fire WIDTH HEIGHT [SLEEP] [RENDERER]\n", .{});
    std.log.info("       SLEEP    - Render loop delay in ms\n", .{});
    std.log.info("       RENDERER - Enable alternate renderer (current just outputs text) by supplying any value\n\n", .{});
}
