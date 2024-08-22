const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libuvCLib = b.dependency("libuv", .{
        .target = target,
        .optimize = optimize,
    });

    const cLibuv = libuvCLib.module("cLibuv");

    const exe = b.addExecutable(.{
        .name = "ZLibuv",
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const ZLibuv = b.addModule(
        "ZLibuv",
        .{
            .root_source_file = b.path("Libuv.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "c", .module = cLibuv }},
        },
    );

    exe.root_module.addImport("ZLibuv", ZLibuv);

    b.installArtifact(exe);
}
