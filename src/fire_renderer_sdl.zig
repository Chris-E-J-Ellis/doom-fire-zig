const fe = @import("fire_engine.zig");
const palette = @import("fire_palette.zig");
const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

const SDL_WINDOWPOS_UNDEFINED = @bitCast(c_int, sdl.SDL_WINDOWPOS_UNDEFINED_MASK);

var back_buffer: []u32 = undefined;
var screen: *sdl.SDL_Window = undefined;
var surface: *sdl.SDL_Surface = undefined;
var texture: *sdl.SDL_Texture = undefined;
var renderer: *sdl.SDL_Renderer = undefined;

pub fn init(buffer: fe.FireBuffer, allocator: *std.mem.Allocator) !fe.FireRenderer {
    try initWindow(buffer);

    back_buffer = try allocator.alloc(u32, (buffer.width * buffer.height));

    return fe.FireRenderer{
        .render_function = renderFire,
        .poll_function = pollForExit,
        .cleanup_function = cleanup,
    };
}

fn initWindow(buffer: fe.FireBuffer) !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        sdl.SDL_Log("Unable to initialize SDL: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    }

    const width = @intCast(c_int, buffer.width);
    const height = @intCast(c_int, buffer.height);

    screen = sdl.SDL_CreateWindow("Doom Fire Effect", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width, height, sdl.SDL_WINDOW_RESIZABLE) orelse {
        sdl.SDL_Log("Unable to create window: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    };

    renderer = sdl.SDL_CreateRenderer(screen, -1, 0) orelse {
        sdl.SDL_Log("Unable to create renderer: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    };

    const surfaceDepth = 32;
    surface = sdl.SDL_CreateRGBSurface(0, width, height, surfaceDepth, 0, 0, 0, 0) orelse {
        sdl.SDL_Log("Unable to create surface", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    };

    texture = sdl.SDL_CreateTextureFromSurface(renderer, surface) orelse {
        sdl.SDL_Log("Unable to create texture from surface: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    };
}

pub fn cleanup() void {
    sdl.SDL_DestroyTexture(texture);
    sdl.SDL_FreeSurface(surface);
    sdl.SDL_DestroyRenderer(renderer);
    sdl.SDL_DestroyWindow(screen);
    sdl.SDL_Quit();
}

pub fn renderFire(buffer: fe.FireBuffer) void {
    var y: usize = 0;
    while (y < buffer.height) : (y += 1) {
        var x: usize = 0;
        while (x < buffer.width) : (x += 1) {
            const pos = x + (y * buffer.width);
            var pixel = buffer.buffer[pos];
            const palette_index = (pixel * 3);

            var r: u32 = palette.doom_rgb_palette[palette_index];
            var g: u16 = palette.doom_rgb_palette[palette_index + 1];
            var b: u8 = palette.doom_rgb_palette[palette_index + 2];

            back_buffer[pos] = r << 16 | g << 8 | b;
        }
    }

    _ = sdl.SDL_UpdateTexture(texture, null, &back_buffer[0], @intCast(c_int, buffer.width * 4));
    _ = sdl.SDL_RenderClear(renderer);
    _ = sdl.SDL_RenderCopy(renderer, texture, null, null);
    _ = sdl.SDL_RenderPresent(renderer);
}

pub fn pollForExit() bool {
    var event: sdl.SDL_Event = undefined;
    while (sdl.SDL_PollEvent(&event) != 0) {
        switch (event.type) {
            sdl.SDL_QUIT => {
                return true;
            },
            sdl.SDL_KEYUP => {
                return true;
            },
            else => {},
        }
    }

    return false;
}
