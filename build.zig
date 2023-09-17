const Builder = @import("std").build.Builder;
const std = @import("std");

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .Debug });
    const exe = b.addExecutable(.{
        .name = "doom-fire",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("sdl2");

    exe.addIncludePath(.{ .cwd_relative = "deps/include" });
    exe.addLibraryPath(.{ .cwd_relative = "deps/lib" });

    // I'm not entirely sure what I'm doing in the build currently,
    // but this will sort my two use cases for the moment =D
    if (target.getOsTag() == .windows) {
        exe.linkSystemLibrary("ole32");
        exe.linkSystemLibrary("oleaut32");
        exe.linkSystemLibrary("imm32");
        exe.linkSystemLibrary("winmm");
        exe.linkSystemLibrary("version");
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("setupapi");
    }
    b.installArtifact(exe);
    //exe.install();

    //const run_cmd = exe.run();
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const default_args = [_][]const u8{ "300", "300" };
    run_cmd.addArgs(&default_args);

    const run_step = b.step("run", "Run the app with default width and height (300x300)");
    run_step.dependOn(&run_cmd.step);
}
