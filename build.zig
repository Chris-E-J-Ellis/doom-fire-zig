const Builder = @import("std").build.Builder;
const std = @import("std");

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("doom-fire", "src/main.zig");
    exe.setTarget(target);

    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("sdl2");

    // I'm not entirely sure what I'm doing in the build currently,
    // but this will sort my two use cases for the moment =D
    if (std.Target.current.os.tag == .windows) {
        exe.addIncludeDir("deps/include");
        exe.addLibPath("deps/lib");
        exe.linkSystemLibrary("ole32");
        exe.linkSystemLibrary("oleaut32");
        exe.linkSystemLibrary("imm32");
        exe.linkSystemLibrary("winmm");
        exe.linkSystemLibrary("version");
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("setupapi");

        exe.setTarget(.{
            .cpu_arch = .x86_64,
            .os_tag = .windows,
            .abi = .gnu,
        });
    }

    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    const default_args = [_][]const u8{ "300", "300" };
    run_cmd.addArgs(&default_args);

    const run_step = b.step("run", "Run the app with default width and height (300x300)");
    run_step.dependOn(&run_cmd.step);
}
