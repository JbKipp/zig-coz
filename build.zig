const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zig_coz",
        .target = target,
        .optimize = optimize,
    });

    lib.addCSourceFile(.{
        .file = b.path("coz_interface.c"),
        .flags = &[_][]const u8{"-g"},
    });

    lib.addIncludePath(b.path("include"));

    lib.linkSystemLibrary("dl");
    lib.linkLibC();

    b.installArtifact(lib);

   _ = b.addModule("zig_coz", .{
        .root_source_file = b.path("coz_interface.zig"),
        .target = target,
        .optimize = .Debug,
    });
}
