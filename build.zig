const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libuvCLib = b.dependency("libuv", .{
        .target = target,
        .optimize = optimize,
    });

    const translatedHeader = libuvCLib.path("c.zig");

    const cLibuv = b.createModule(.{
        .root_source_file = translatedHeader,
        .link_libc = true,
    });

    const exe = b.addExecutable(.{
        .name = "ZLibuv",
        .root_source_file = .{ .cwd_relative = "main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const ZLibuv = b.addModule(
        "ZLibuv",
        .{
            .root_source_file = .{ .cwd_relative = "Libuv.zig" },
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "c", .module = cLibuv }},
        },
    );

    ZLibuv.linkLibrary(libuvCLib.artifact("libuv"));

    exe.root_module.addImport("ZLibuv", ZLibuv);
    exe.step.dependOn(&libuvCLib.artifact("libuv").step);

    b.installArtifact(exe);
}
