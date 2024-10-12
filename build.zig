const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libuvCLib = b.dependency("libuv", .{
        .target = target,
        .optimize = optimize,
    });

    const cLibuv = libuvCLib.module("cLibuv");

    const ZLibuv = b.addModule(
        "ZLibuv",
        .{
            .root_source_file = b.path("Libuv.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "c", .module = cLibuv }},
        },
    );

    const ZLibuvUnitTests = b.addTest(.{
        .root_source_file = b.path("src/Test.zig"),
        .target = target,
        .optimize = optimize,
    });

    ZLibuvUnitTests.root_module.addImport("ZLibuv", ZLibuv);

    const UnitTestRun = b.addRunArtifact(ZLibuvUnitTests);

    const TestStep = b.step("test", "Run unit tests");
    TestStep.dependOn(&UnitTestRun.step);
}
